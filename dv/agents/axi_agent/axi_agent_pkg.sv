package axi_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "axi_seq_item.sv"
  `include "axi_agent_cfg.sv"
  `include "axi_driver.sv"
  `include "axi_monitor.sv"
  `include "axi_sequencer.sv"
  `include "axi_agent.sv"
  `include "seq_lib/axi_base_seq.sv"
  `include "seq_lib/axi_rand_write_seq.sv"
endpackage : axi_agent_pkg
