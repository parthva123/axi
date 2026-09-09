module axi_sys_sva #(
  parameter string AXI_PROTOCOL = "AXI4", parameter int M_AXI_ID_WIDTH = 4,
  parameter bit LAST_BRIDGE = 0, parameter bit PCIE_LAST_BRIDGE = 0, parameter bit PCIE_AXI = 0
) (
  input logic axi_aclk, input logic axi_aresetn, input logic [3:0] usr_resetn,
  input logic m_axi_awvalid, input logic m_axi_arvalid, input logic m_axi_wvalid
);
  initial begin
    assert ((AXI_PROTOCOL == "AXI4") + (AXI_PROTOCOL == "AXI3") + (AXI_PROTOCOL == "AXI4LITE") == 1)
      else $fatal(1, "SYS-ASSERT-01 FAIL: Illegal or ambiguous AXI_PROTOCOL parameter");
  end

  genvar gi;
  generate
    for (gi = 0; gi < 4; gi++) begin : gen_usr_rst_seq
      property p_usr_resetn_seq;
        @(posedge axi_aclk) $rose(usr_resetn[gi]) |-> $past(axi_aresetn, 4);
      endproperty
      a_usr_resetn_seq: assert property(p_usr_resetn_seq) else $error("SYS-ASSERT-02 FAIL[%0d]", gi);
    end
  endgenerate

  property p_no_activity_in_reset;
    @(posedge axi_aclk) !axi_aresetn |-> (!m_axi_awvalid && !m_axi_arvalid && !m_axi_wvalid);
  endproperty
  a_no_activity_in_reset: assert property(p_no_activity_in_reset) else $error("SYS-ASSERT-03 FAIL");

  initial begin
    assert (M_AXI_ID_WIDTH >= 4 && M_AXI_ID_WIDTH <= 16)
      else $fatal(1, "SYS-ASSERT-04 FAIL: M_AXI_ID_WIDTH out of supported range");
  end

  initial begin
    assert (!(LAST_BRIDGE && PCIE_LAST_BRIDGE && !PCIE_AXI))
      else $fatal(1, "SYS-ASSERT-05 FAIL: Inconsistent bridge-chaining parameter combination");
  end
endmodule : axi_sys_sva
