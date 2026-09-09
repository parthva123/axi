package axi_bridge_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi_agent_pkg::*;
  import reg_intr_agent_pkg::*;
  import axi_bridge_ral_pkg::*;

  parameter int RAM_SIZE     = 16384;
  parameter int M_AXI_ADDR_W = 64;
  parameter int M_AXI_DATA_W = 128;
  parameter int M_AXI_ID_W   = 16;   // FIXED: matches real RTL default (was wrongly 4)
  parameter int M_AXI_USER_W = 32;
  parameter int S_AXI_ADDR_W = 64;
  parameter int S_AXI_DATA_W = 32;
  // ADDED: real S_AXI_USR data-plane port parameters (verified against slave_all.v)
  parameter int S_AXI_USR_ADDR_W = 64;
  parameter int S_AXI_USR_DATA_W = 128;
  parameter int S_AXI_USR_ID_W   = 16;

  typedef enum { AXI_PROTO_AXI4, AXI_PROTO_AXI3, AXI_PROTO_AXI4LITE } axi_protocol_e;

  typedef struct {
    bit [31:0] txn_type;
    bit [31:0] size;
    bit [31:0] data_offset;
    bit [31:0] data_host_addr[4];
    bit [31:0] wstrb_host_addr[4];
    bit [31:0] axsize;
    bit [31:0] attr;
    bit [31:0] axaddr[4];
    bit [31:0] axid[4];
    bit        ownership;
    bit        busy;
  } desc_t;

  `include "axi_reg_adapter.sv"
  `include "axi_reg_predictor_wrapper.sv"
  `include "axi_bridge_env_cfg.sv"
  `include "axi_bridge_env_cov.sv"
  `include "axi_bridge_scoreboard.sv"
  `include "axi_bridge_virtual_sequencer.sv"
  `include "axi_bridge_irq_cov_subscriber.sv"
  `include "axi_bridge_env.sv"

  `include "seq_lib/axi_bridge_base_vseq.sv"
  `include "seq_lib/axi_bridge_smoke_vseq.sv"
  `include "seq_lib/axi_bridge_desc_dma_vseq.sv"
  `include "seq_lib/axi_bridge_ral_smoke_vseq.sv"
  `include "seq_lib/axi_bridge_slv_passthrough_vseq.sv"
endpackage : axi_bridge_env_pkg
