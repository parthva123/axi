#!/usr/bin/env python3
"""gen_testplan_doc.py - emits a Markdown testplan table from the HJSON testplan."""
import sys, hjson

def main():
    if len(sys.argv) != 2:
        print("Usage: gen_testplan_doc.py <testplan.hjson>", file=sys.stderr); sys.exit(1)
    with open(sys.argv[1], "r") as f:
        plan = hjson.load(f)
    print(f"# {plan['name']} Testplan\n")
    print("| Testpoint | Description | Tags | Tests |")
    print("|---|---|---|---|")
    for tp in plan.get("testpoints", []):
        print(f"| {tp['name']} | {tp['desc']} | {', '.join(tp.get('tags', []))} | {', '.join(tp.get('tests', []))} |")
    print("\n## Covergroups\n")
    print("| Covergroup | Description |")
    print("|---|---|")
    for cg in plan.get("covergroups", []):
        print(f"| {cg['name']} | {cg['desc']} |")

if __name__ == "__main__":
    main()
