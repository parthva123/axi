`timescale 1ns/1ps

module tb;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi_agent_pkg::*;
  import axi_bridge_env_pkg::*;
  import axi_bridge_test_pkg::*;

  wire axi_aclk;
  wire axi_aresetn;
  wire [3:0] usr_resetn;   // FIXED: this is a DUT OUTPUT, not a tied-off input

  clk_rst_if clk_rst_if0 (.clk(axi_aclk), .rst_n(axi_aresetn));

  // S_AXI: 32-bit AXI4-Lite config/register/descriptor-programming port.
  // Real RTL name is s_axi_*, not s_axi_usr_*.
  axi_if #(.ADDR_WIDTH(64), .DATA_WIDTH(32), .ID_WIDTH(4), .USER_WIDTH(32))
    s_axi_cfg_if (.clk(axi_aclk), .rst_n(axi_aresetn));

  // S_AXI_USR: the REAL data-plane slave port - full AXI4, 128-bit, own
  // 16-bit ID space. This was missing entirely from the original TB;
  // it's the port that actually gets bridged through to M_AXI.
  axi_if #(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32))
    s_axi_usr_if (.clk(axi_aclk), .rst_n(axi_aresetn));

  // M_AXI: 128-bit AXI4 master port - passive monitor + needs a memory
  // model responder (see m_axi_mem_model.sv) or every DUT transaction hangs.
  axi_if #(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32))
    m_axi_if (.clk(axi_aclk), .rst_n(axi_aresetn));

  reg_intr_if reg_intr_if0 (.clk(axi_aclk), .rst_n(axi_aresetn));

  axi_bridge_top #(
    .M_AXI_ADDR_WIDTH (M_AXI_ADDR_W),
    .M_AXI_DATA_WIDTH (M_AXI_DATA_W),
    .M_AXI_ID_WIDTH   (M_AXI_ID_W),
    .M_AXI_USER_WIDTH (M_AXI_USER_W),
    .S_AXI_ADDR_WIDTH (S_AXI_ADDR_W),
    .S_AXI_DATA_WIDTH (S_AXI_DATA_W),
    .S_AXI_USR_ADDR_WIDTH (S_AXI_USR_ADDR_W),
    .S_AXI_USR_DATA_WIDTH (S_AXI_USR_DATA_W),
    .S_AXI_USR_ID_WIDTH   (S_AXI_USR_ID_W),
    .RAM_SIZE         (RAM_SIZE),
    .MAX_DESC         (`AXI_BRIDGE_MAX_DESC)
  ) dut (
    .axi_aclk     (axi_aclk),
    .axi_aresetn  (axi_aresetn),
    .usr_resetn   (usr_resetn),

    .irq_out       (reg_intr_if0.irq_out),
    .irq_ack       (reg_intr_if0.irq_ack),
    .h2c_intr_out  (reg_intr_if0.h2c_intr_out),
    .c2h_intr_in   (reg_intr_if0.c2h_intr_in),
    .h2c_pulse_out (reg_intr_if0.h2c_pulse_out),
    .c2h_gpio_in   (reg_intr_if0.c2h_gpio_in),
    .h2c_gpio_out  (reg_intr_if0.h2c_gpio_out),

    // S_AXI - AXI4-Lite config/register/descriptor port
    .s_axi_awaddr  (s_axi_cfg_if.awaddr[S_AXI_ADDR_W-1:0]),
    .s_axi_awprot  (3'b000),
    .s_axi_awvalid (s_axi_cfg_if.awvalid),
    .s_axi_awready (s_axi_cfg_if.awready),
    .s_axi_wdata   (s_axi_cfg_if.wdata),
    .s_axi_wstrb   (s_axi_cfg_if.wstrb),
    .s_axi_wvalid  (s_axi_cfg_if.wvalid),
    .s_axi_wready  (s_axi_cfg_if.wready),
    .s_axi_bresp   (s_axi_cfg_if.bresp),
    .s_axi_bvalid  (s_axi_cfg_if.bvalid),
    .s_axi_bready  (s_axi_cfg_if.bready),
    .s_axi_araddr  (s_axi_cfg_if.araddr[S_AXI_ADDR_W-1:0]),
    .s_axi_arprot  (3'b000),
    .s_axi_arvalid (s_axi_cfg_if.arvalid),
    .s_axi_arready (s_axi_cfg_if.arready),
    .s_axi_rdata   (s_axi_cfg_if.rdata),
    .s_axi_rresp   (s_axi_cfg_if.rresp),
    .s_axi_rvalid  (s_axi_cfg_if.rvalid),
    .s_axi_rready  (s_axi_cfg_if.rready),

    // S_AXI_USR - real data-plane AXI4 slave port
    .s_axi_usr_awid    (s_axi_usr_if.awid),
    .s_axi_usr_awaddr  (s_axi_usr_if.awaddr),
    .s_axi_usr_awlen   (s_axi_usr_if.awlen),
    .s_axi_usr_awsize  (s_axi_usr_if.awsize),
    .s_axi_usr_awburst (s_axi_usr_if.awburst),
    .s_axi_usr_awlock  (s_axi_usr_if.awlock),
    .s_axi_usr_awcache (s_axi_usr_if.awcache),
    .s_axi_usr_awprot  (s_axi_usr_if.awprot),
    .s_axi_usr_awqos   (s_axi_usr_if.awqos),
    .s_axi_usr_awregion(s_axi_usr_if.awregion),
    .s_axi_usr_awuser  (s_axi_usr_if.awuser),
    .s_axi_usr_awvalid (s_axi_usr_if.awvalid),
    .s_axi_usr_awready (s_axi_usr_if.awready),
    .s_axi_usr_wdata   (s_axi_usr_if.wdata),
    .s_axi_usr_wstrb   (s_axi_usr_if.wstrb),
    .s_axi_usr_wlast   (s_axi_usr_if.wlast),
    .s_axi_usr_wid     (s_axi_usr_if.awid),   // AXI3-style WID tie-off (unused on AXI4); harmless on AXI4 config
    .s_axi_usr_wuser   (s_axi_usr_if.wuser),
    .s_axi_usr_wvalid  (s_axi_usr_if.wvalid),
    .s_axi_usr_wready  (s_axi_usr_if.wready),
    .s_axi_usr_bid     (s_axi_usr_if.bid),
    .s_axi_usr_bresp   (s_axi_usr_if.bresp),
    .s_axi_usr_buser   (s_axi_usr_if.buser),
    .s_axi_usr_bvalid  (s_axi_usr_if.bvalid),
    .s_axi_usr_bready  (s_axi_usr_if.bready),
    .s_axi_usr_arid    (s_axi_usr_if.arid),
    .s_axi_usr_araddr  (s_axi_usr_if.araddr),
    .s_axi_usr_arlen   (s_axi_usr_if.arlen),
    .s_axi_usr_arsize  (s_axi_usr_if.arsize),
    .s_axi_usr_arburst (s_axi_usr_if.arburst),
    .s_axi_usr_arlock  (s_axi_usr_if.arlock),
    .s_axi_usr_arcache (s_axi_usr_if.arcache),
    .s_axi_usr_arprot  (s_axi_usr_if.arprot),
    .s_axi_usr_arqos   (s_axi_usr_if.arqos),
    .s_axi_usr_arregion(s_axi_usr_if.arregion),
    .s_axi_usr_aruser  (s_axi_usr_if.aruser),
    .s_axi_usr_arvalid (s_axi_usr_if.arvalid),
    .s_axi_usr_arready (s_axi_usr_if.arready),
    .s_axi_usr_rid     (s_axi_usr_if.rid),
    .s_axi_usr_rdata   (s_axi_usr_if.rdata),
    .s_axi_usr_rresp   (s_axi_usr_if.rresp),
    .s_axi_usr_rlast   (s_axi_usr_if.rlast),
    .s_axi_usr_ruser   (s_axi_usr_if.ruser),
    .s_axi_usr_rvalid  (s_axi_usr_if.rvalid),
    .s_axi_usr_rready  (s_axi_usr_if.rready),

    // M_AXI - master port (needs mem-model responder, see m_axi_mem_model.sv)
    .m_axi_awid    (m_axi_if.awid),
    .m_axi_awaddr  (m_axi_if.awaddr),
    .m_axi_awlen   (m_axi_if.awlen),
    .m_axi_awsize  (m_axi_if.awsize),
    .m_axi_awburst (m_axi_if.awburst),
    .m_axi_awlock  (m_axi_if.awlock),
    .m_axi_awcache (m_axi_if.awcache),
    .m_axi_awprot  (m_axi_if.awprot),
    .m_axi_awqos   (m_axi_if.awqos),
    .m_axi_awregion(m_axi_if.awregion),
    .m_axi_awuser  (m_axi_if.awuser),
    .m_axi_awvalid (m_axi_if.awvalid),
    .m_axi_awready (m_axi_if.awready),
    .m_axi_wdata   (m_axi_if.wdata),
    .m_axi_wstrb   (m_axi_if.wstrb),
    .m_axi_wlast   (m_axi_if.wlast),
    .m_axi_wuser   (m_axi_if.wuser),
    .m_axi_wvalid  (m_axi_if.wvalid),
    .m_axi_wready  (m_axi_if.wready),
    .m_axi_bid     (m_axi_if.bid),
    .m_axi_bresp   (m_axi_if.bresp),
    .m_axi_buser   (m_axi_if.buser),
    .m_axi_bvalid  (m_axi_if.bvalid),
    .m_axi_bready  (m_axi_if.bready),
    .m_axi_arid    (m_axi_if.arid),
    .m_axi_araddr  (m_axi_if.araddr),
    .m_axi_arlen   (m_axi_if.arlen),
    .m_axi_arsize  (m_axi_if.arsize),
    .m_axi_arburst (m_axi_if.arburst),
    .m_axi_arlock  (m_axi_if.arlock),
    .m_axi_arcache (m_axi_if.arcache),
    .m_axi_arprot  (m_axi_if.arprot),
    .m_axi_arqos   (m_axi_if.arqos),
    .m_axi_arregion(m_axi_if.arregion),
    .m_axi_aruser  (m_axi_if.aruser),
    .m_axi_arvalid (m_axi_if.arvalid),
    .m_axi_arready (m_axi_if.arready),
    .m_axi_rid     (m_axi_if.rid),
    .m_axi_rdata   (m_axi_if.rdata),
    .m_axi_rresp   (m_axi_if.rresp),
    .m_axi_rlast   (m_axi_if.rlast),
    .m_axi_ruser   (m_axi_if.ruser),
    .m_axi_rvalid  (m_axi_if.rvalid),
    .m_axi_rready  (m_axi_if.rready)
  );

  // M_AXI memory-model responder - makes the DUT's master-side transactions
  // actually complete (awready/wready/bvalid/arready/rvalid/rdata). Without
  // this nothing the DUT issues on M_AXI ever finishes.
  m_axi_mem_model #(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .MEM_SIZE_BYTES(RAM_SIZE))
    u_m_axi_mem_model (.axi_if(m_axi_if.slave));

  // bind axi_bridge_top axi_bridge_sva_checker u_sva_checker (.*); // see dv/sva/

  initial begin
    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "clk_rst_vif", clk_rst_if0);

    uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(32),.ID_WIDTH(4),.USER_WIDTH(32)))::
      set(null, "*s_axi_cfg_agent*", "vif", s_axi_cfg_if);
    uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(128),.ID_WIDTH(16),.USER_WIDTH(32)))::
      set(null, "*s_axi_usr_agent*", "vif", s_axi_usr_if);
    uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(128),.ID_WIDTH(16),.USER_WIDTH(32)))::
      set(null, "*m_axi_mon_agent*", "vif", m_axi_if);
    uvm_config_db#(virtual reg_intr_if)::set(null, "*reg_intr_agt*", "vif", reg_intr_if0);

    clk_rst_if0.start_clk(10.0);
    run_test();
  end

  initial begin
    if ($test$plusargs("DUMP_VCD")) begin
      $dumpfile("waves.vcd");
      $dumpvars(0, tb);
    end
  end

  initial begin
    int timeout_ns = 1_000_000;
    if ($value$plusargs("TIMEOUT_NS=%d", timeout_ns)) ;
    #(timeout_ns);
    `uvm_fatal("TB_TIMEOUT", $sformatf("Global timeout of %0d ns reached", timeout_ns))
  end
endmodule : tb
