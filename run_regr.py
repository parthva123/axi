#!/usr/bin/env python3
"""
run_regr.py - Python-based regression driver for the axi_bridge UVM
testbench, orchestrating VCS compile/sim/coverage the way OpenTitan's
dvsim.py does (Python drives the flow; SV/UVM does the actual checking).
"""
import argparse, json, re, subprocess, sys, time
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Optional

try:
    import hjson
except ImportError:
    print("ERROR: install the 'hjson' package: pip install hjson", file=sys.stderr)
    sys.exit(1)


@dataclass
class TestResult:
    name: str
    seed: int
    passed: bool
    errors: int
    warnings: int
    log_path: str
    duration_s: float


@dataclass
class RegressionReport:
    results: List[TestResult] = field(default_factory=list)

    def add(self, r: TestResult): self.results.append(r)

    @property
    def total(self): return len(self.results)
    @property
    def num_passed(self): return sum(1 for r in self.results if r.passed)
    @property
    def num_failed(self): return self.total - self.num_passed

    def summary_table(self) -> str:
        lines = [f"{'TEST':40s} {'SEED':>10s} {'STATUS':>8s} {'ERR':>5s} {'WARN':>6s} {'TIME(s)':>8s}"]
        lines.append("-" * 85)
        for r in self.results:
            status = "PASS" if r.passed else "FAIL"
            lines.append(f"{r.name:40s} {r.seed:>10d} {status:>8s} {r.errors:>5d} "
                          f"{r.warnings:>6d} {r.duration_s:>8.1f}")
        lines.append("-" * 85)
        lines.append(f"TOTAL: {self.total}  PASSED: {self.num_passed}  FAILED: {self.num_failed}")
        return "\n".join(lines)


class SimConfig:
    def __init__(self, cfg_path: str):
        with open(cfg_path, "r") as f:
            self.raw = hjson.load(f)
        self.name = self.raw["name"]
        self.sv_flist = self.raw["sv_flist"]
        self.incdirs = self.raw.get("incdirs", [])
        self.build_opts = self.raw.get("build_opts", [])
        self.tests = {t["name"]: t for t in self.raw.get("tests", [])}
        self.regressions = {r["name"]: r for r in self.raw.get("regressions", [])}
        self.default_verbosity = self.raw.get("default_verbosity", "UVM_MEDIUM")
        self.default_seed_count = self.raw.get("default_seed_count", 1)


class Runner:
    def __init__(self, cfg: SimConfig, workdir: str = "sim_out"):
        self.cfg = cfg
        self.workdir = Path(workdir); self.workdir.mkdir(parents=True, exist_ok=True)
        self.build_dir = self.workdir / "build"; self.build_dir.mkdir(parents=True, exist_ok=True)
        self.cov_dir = self.workdir / "cov"; self.cov_dir.mkdir(parents=True, exist_ok=True)

    def build_cmd(self) -> List[str]:
        cmd = ["vcs"] + self.cfg.build_opts
        for inc in self.cfg.incdirs:
            cmd += [f"+incdir+{inc}"]
        cmd += self.cfg.sv_flist
        cmd += ["-o", str(self.build_dir / "simv"), "-cm", "line+cond+fsm+branch+tgl"]
        return cmd

    def run_cmd(self, test_name: str, seed: int, verbosity: str) -> List[str]:
        simv = str(self.build_dir / "simv")
        cov_dir = str(self.cov_dir / f"{test_name}_{seed}")
        return [simv, f"+UVM_TESTNAME={test_name}", f"+UVM_VERBOSITY={verbosity}",
                f"+ntb_random_seed={seed}", "-cm", "line+cond+fsm+branch+tgl", "-cm_dir", cov_dir]

    def do_build(self) -> bool:
        print(f"[run_regr] Building DUT+TB ({self.cfg.name}) ...")
        log_path = self.build_dir / "build.log"
        with open(log_path, "w") as logf:
            proc = subprocess.run(self.build_cmd(), stdout=logf, stderr=subprocess.STDOUT)
        ok = proc.returncode == 0
        print(f"[run_regr] Build {'PASSED' if ok else 'FAILED'} - log: {log_path}")
        return ok

    def do_run(self, test_name: str, seed: int, verbosity: str) -> TestResult:
        log_dir = self.workdir / "run_logs"; log_dir.mkdir(parents=True, exist_ok=True)
        log_path = log_dir / f"{test_name}_{seed}.log"
        start = time.time()
        with open(log_path, "w") as logf:
            proc = subprocess.run(self.run_cmd(test_name, seed, verbosity), stdout=logf, stderr=subprocess.STDOUT)
        duration = time.time() - start
        errors, warnings, passed = self._parse_log(log_path)
        return TestResult(test_name, seed, passed, errors, warnings, str(log_path), duration)

    @staticmethod
    def _parse_log(log_path: Path):
        text = log_path.read_text(errors="ignore")
        errors = len(re.findall(r"^\s*UVM_ERROR", text, re.MULTILINE))
        warnings = len(re.findall(r"^\s*UVM_WARNING", text, re.MULTILINE))
        fatal = len(re.findall(r"^\s*UVM_FATAL", text, re.MULTILINE))
        passed = ("TEST PASSED" in text) and (errors == 0) and (fatal == 0)
        return errors, warnings, passed

    def merge_coverage(self) -> Optional[str]:
        merged_dir = self.workdir / "cov_merged"
        cov_dbs = [str(p) for p in self.cov_dir.glob("*") if p.is_dir()]
        if not cov_dbs:
            print("[run_regr] No coverage databases found, skipping merge")
            return None
        cmd = ["urg", "-dir"] + cov_dbs + ["-dbname", str(merged_dir / "merged.vdb"),
                                            "-report", str(merged_dir / "report")]
        print(f"[run_regr] Merging coverage: {' '.join(cmd)}")
        subprocess.run(cmd)
        return str(merged_dir / "report")


def load_testplan(testplan_path: str) -> dict:
    with open(testplan_path, "r") as f:
        return hjson.load(f)


def cross_check_testplan(testplan: dict, executed_tests: List[str]) -> None:
    print("\n[run_regr] Testplan cross-check:")
    executed_set = set(executed_tests)
    for tp in testplan.get("testpoints", []):
        planned_tests = set(tp.get("tests", []))
        hit = planned_tests & executed_set
        status = "COVERED" if hit else "NOT RUN"
        print(f"  [{status:8s}] {tp['name']:25s} - {tp['desc']}")


def main():
    ap = argparse.ArgumentParser(description="axi_bridge UVM regression runner")
    ap.add_argument("sim_cfg")
    ap.add_argument("--testplan", default=None)
    ap.add_argument("--test", action="append", default=[])
    ap.add_argument("--regression", default=None)
    ap.add_argument("--seeds", type=int, default=None)
    ap.add_argument("--verbosity", default=None)
    ap.add_argument("--skip-build", action="store_true")
    ap.add_argument("--workdir", default="sim_out")
    args = ap.parse_args()

    cfg = SimConfig(args.sim_cfg)
    runner = Runner(cfg, workdir=args.workdir)

    if not args.skip_build:
        if not runner.do_build():
            print("[run_regr] Build failed, aborting.")
            sys.exit(1)

    if args.test:
        test_names = args.test
    elif args.regression:
        reg = cfg.regressions.get(args.regression)
        if reg is None:
            print(f"[run_regr] Unknown regression '{args.regression}'"); sys.exit(1)
        test_names = reg["tests"]
    else:
        test_names = list(cfg.tests.keys()) or ["axi_bridge_smoke_test"]

    verbosity = args.verbosity or cfg.default_verbosity
    seed_count = args.seeds or cfg.default_seed_count

    report = RegressionReport()
    for test_name in test_names:
        reruns = cfg.tests.get(test_name, {}).get("reruns", seed_count)
        for i in range(reruns):
            seed = 1000 + i
            print(f"[run_regr] Running {test_name} seed={seed} ...")
            result = runner.do_run(test_name, seed, verbosity)
            report.add(result)
            print(f"  -> {'PASS' if result.passed else 'FAIL'} "
                  f"(errors={result.errors}, warnings={result.warnings}, {result.duration_s:.1f}s)")

    print("\n" + report.summary_table())

    cov_report = runner.merge_coverage()
    if cov_report:
        print(f"[run_regr] Merged coverage report: {cov_report}")

    if args.testplan:
        cross_check_testplan(load_testplan(args.testplan), test_names)

    results_json = Path(args.workdir) / "results.json"
    with open(results_json, "w") as f:
        json.dump([r.__dict__ for r in report.results], f, indent=2)
    print(f"[run_regr] Results written to {results_json}")

    sys.exit(0 if report.num_failed == 0 else 1)


if __name__ == "__main__":
    main()
