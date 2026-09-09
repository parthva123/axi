module axi_master_write_sva #(
  parameter int DATA_WIDTH = 128, parameter int ADDR_WIDTH = 64, parameter int ID_WIDTH = 4
) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic m_axi_awvalid, input logic m_axi_awready,
  input logic [ADDR_WIDTH-1:0] m_axi_awaddr, input logic [7:0] m_axi_awlen, input logic [2:0] m_axi_awsize,
  input logic m_axi_wvalid, input logic m_axi_wready, input logic m_axi_wlast,
  input logic m_axi_bvalid, input logic m_axi_bready
);
  int wcnt;
  bit aw_w_txn_accepted;

  always @(posedge axi_aclk) begin
    if (!axi_aresetn) wcnt <= 0;
    else if (m_axi_wvalid && m_axi_wready) wcnt <= m_axi_wlast ? 0 : wcnt + 1;
  end
  always @(posedge axi_aclk) begin
    if (!axi_aresetn) aw_w_txn_accepted <= 0;
    else if (m_axi_wvalid && m_axi_wready && m_axi_wlast) aw_w_txn_accepted <= 1;
    else if (m_axi_bvalid && m_axi_bready) aw_w_txn_accepted <= 0;
  end

  property p_m_axi_awvalid_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_awvalid && !m_axi_awready |=> m_axi_awvalid;
  endproperty
  a_m_axi_awvalid_stable: assert property(p_m_axi_awvalid_stable) else $error("MWR-ASSERT-01 FAIL");

  property p_m_axi_aw_awaddr_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) (m_axi_awvalid && !m_axi_awready) |=> $stable(m_axi_awaddr);
  endproperty
  a_m_axi_aw_awaddr_stable: assert property(p_m_axi_aw_awaddr_stable) else $error("MWR-ASSERT-02 FAIL");

  property p_m_axi_wvalid_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_wvalid && !m_axi_wready |=> m_axi_wvalid;
  endproperty
  a_m_axi_wvalid_stable: assert property(p_m_axi_wvalid_stable) else $error("MWR-ASSERT-03 FAIL");

  property p_m_axi_wlast_count;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    (m_axi_wvalid && m_axi_wready && m_axi_wlast) |-> (wcnt == m_axi_awlen);
  endproperty
  a_m_axi_wlast_count: assert property(p_m_axi_wlast_count) else $error("MWR-ASSERT-04 FAIL");

  property p_m_axi_bvalid_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_bvalid && !m_axi_bready |=> m_axi_bvalid;
  endproperty
  a_m_axi_bvalid_stable: assert property(p_m_axi_bvalid_stable) else $error("MWR-ASSERT-05 FAIL");

  property p_m_axi_bvalid_order;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_bvalid |-> $past(aw_w_txn_accepted);
  endproperty
  a_m_axi_bvalid_order: assert property(p_m_axi_bvalid_order) else $error("MWR-ASSERT-06 FAIL");

  property p_m_axi_awsize_legal;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_awvalid |-> (m_axi_awsize <= $clog2(DATA_WIDTH/8));
  endproperty
  a_m_axi_awsize_legal: assert property(p_m_axi_awsize_legal) else $error("MWR-ASSERT-07 FAIL");

  property p_m_axi_aw_addr_no_x;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_awvalid |-> !$isunknown(m_axi_awaddr);
  endproperty
  a_m_axi_aw_addr_no_x: assert property(p_m_axi_aw_addr_no_x) else $error("MWR-ASSERT-08 FAIL");
endmodule : axi_master_write_sva
