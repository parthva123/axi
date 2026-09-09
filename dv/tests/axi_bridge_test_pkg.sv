package axi_bridge_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi_agent_pkg::*;
  import reg_intr_agent_pkg::*;
  import axi_bridge_env_pkg::*;

  `include "axi_bridge_base_test.sv"
  `include "axi_bridge_smoke_test.sv"
  `include "axi_bridge_desc_dma_test.sv"
  `include "axi_bridge_reg_intr_test.sv"
  `include "axi_bridge_arb_test.sv"
  `include "axi_bridge_infra_test.sv"
  `include "axi_bridge_sys_test.sv"
  `include "axi_bridge_ral_smoke_test.sv"
  `include "axi_bridge_slv_passthrough_test.sv"
endpackage : axi_bridge_test_pkg
