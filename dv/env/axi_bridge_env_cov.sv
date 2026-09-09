class axi_bridge_env_cov extends uvm_component;
  `uvm_component_utils(axi_bridge_env_cov)

  axi_bridge_env_cfg cfg;

  bit [1:0]  cov_awburst, cov_arburst;
  bit [7:0]  cov_awlen,   cov_arlen;
  bit [2:0]  cov_awsize,  cov_arsize;
  bit [1:0]  cov_bresp,   cov_rresp;
  bit [3:0]  cov_awid,    cov_arid;
  bit [15:0] cov_wstrb;
  bit        cov_extend_wstrb;
  bit [3:0]  cov_desc_idx;
  bit [31:0] cov_desc_txn_type;
  bit        cov_ownership_flip;
  bit [3:0]  cov_gnt_idx;
  bit        cov_fifo_full, cov_fifo_empty;
  axi_protocol_e cov_protocol;

  covergroup cg_axi_write with function sample();
    cp_awburst: coverpoint cov_awburst { bins fixed={2'b00}; bins incr={2'b01}; bins wrap={2'b10}; }
    cp_awlen: coverpoint cov_awlen {
      bins single={0}; bins short_b={[1:14]}; bins bl16={15}; bins mid={[16:127]}; bins max_len={255};
    }
    cp_awsize: coverpoint cov_awsize { bins sz[] = {[0:4]}; }
    cp_bresp: coverpoint cov_bresp { bins okay={2'b00}; bins exokay={2'b01}; bins slverr={2'b10}; bins decerr={2'b11}; }
    cp_wstrb: coverpoint cov_wstrb {
      bins all_ones={16'hFFFF}; bins all_zero={16'h0000};
      bins one_byte={16'h0001,16'h0002,16'h0008,16'h8000}; bins alt={16'h5555,16'hAAAA};
    }
    cp_awid: coverpoint cov_awid { bins id[] = {[0:15]}; }
    cx_burst_len: cross cp_awburst, cp_awlen;
    cx_bresp_burst: cross cp_bresp, cp_awburst;
  endgroup

  covergroup cg_axi_read with function sample();
    cp_arburst: coverpoint cov_arburst { bins fixed={2'b00}; bins incr={2'b01}; bins wrap={2'b10}; }
    cp_arlen: coverpoint cov_arlen {
      bins single={0}; bins short_b={[1:14]}; bins bl16={15}; bins mid={[16:127]}; bins max_len={255};
    }
    cp_rresp: coverpoint cov_rresp { bins okay={2'b00}; bins exokay={2'b01}; bins slverr={2'b10}; bins decerr={2'b11}; }
    cp_arid: coverpoint cov_arid { bins id[] = {[0:15]}; }
    cx_burst_len: cross cp_arburst, cp_arlen;
  endgroup

  covergroup cg_descriptor with function sample();
    cp_desc_idx: coverpoint cov_desc_idx { bins idx[] = {[0:15]}; }
    cp_txn_type: coverpoint cov_desc_txn_type { bins wr={0}; bins rd={1}; }
    cp_own_flip: coverpoint cov_ownership_flip { bins flip={1}; }
    cx_desc_type: cross cp_desc_idx, cp_txn_type;
  endgroup

  covergroup cg_arbitration with function sample();
    cp_gnt_idx: coverpoint cov_gnt_idx { bins idx[] = {[0:15]}; }
  endgroup

  covergroup cg_infra with function sample();
    cp_fifo_full:  coverpoint cov_fifo_full  { bins full={1};  }
    cp_fifo_empty: coverpoint cov_fifo_empty { bins empty={1}; }
    cp_extend_wstrb: coverpoint cov_extend_wstrb { bins on={1}; bins off={0}; }
  endgroup

  covergroup cg_system with function sample();
    cp_protocol: coverpoint cov_protocol {
      bins axi4={AXI_PROTO_AXI4}; bins axi3={AXI_PROTO_AXI3}; bins axi4lite={AXI_PROTO_AXI4LITE};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_axi_write   = new();
    cg_axi_read    = new();
    cg_descriptor  = new();
    cg_arbitration = new();
    cg_infra       = new();
    cg_system      = new();
  endfunction

  // Called from: axi_bridge_scoreboard.check_txn() (see FIXED scoreboard below)
  function void write_write_txn(axi_seq_item item);
    cov_awburst = item.burst; cov_awlen = item.len; cov_awsize = item.size;
    cov_bresp = item.resp; cov_awid = item.id;
    if (item.wstrb.size() > 0) cov_wstrb = item.wstrb[0];
    cg_axi_write.sample();
  endfunction

  function void write_read_txn(axi_seq_item item);
    cov_arburst = item.burst; cov_arlen = item.len; cov_arsize = item.size;
    cov_rresp = item.resp; cov_arid = item.id;
    cg_axi_read.sample();
  endfunction

  // Called from: axi_bridge_scoreboard.predict_desc_txn() (FIXED - now wired)
  function void write_desc_event(bit [3:0] idx, bit [31:0] txn_type, bit own_flip);
    cov_desc_idx = idx; cov_desc_txn_type = txn_type; cov_ownership_flip = own_flip;
    cg_descriptor.sample();
  endfunction

  // Called from: reg_intr_monitor.mon_grant() (FIXED - now wired)
  function void write_grant_event(bit [3:0] gnt_idx);
    cov_gnt_idx = gnt_idx;
    cg_arbitration.sample();
  endfunction

  // Called from: axi_bridge_scoreboard on beat-count mismatch / infra tests (FIXED - now wired)
  function void write_infra_event(bit fifo_full, bit fifo_empty, bit ext_wstrb);
    cov_fifo_full = fifo_full; cov_fifo_empty = fifo_empty; cov_extend_wstrb = ext_wstrb;
    cg_infra.sample();
  endfunction

  function void write_system_event(axi_protocol_e proto);
    cov_protocol = proto;
    cg_system.sample();
  endfunction
endclass : axi_bridge_env_cov
