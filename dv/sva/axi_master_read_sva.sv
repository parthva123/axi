module axi_master_read_sva #(
  parameter int DATA_WIDTH = 128, parameter int ADDR_WIDTH = 64, parameter int ID_WIDTH = 4
) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic m_axi_arvalid, input logic m_axi_arready,
  input logic [ADDR_WIDTH-1:0] m_axi_araddr, input logic [7:0] m_axi_arlen, input logic [2:0] m_axi_arsize,
  input logic [ID_WIDTH-1:0] m_axi_arid,
  input logic m_axi_rvalid, input logic m_axi_rready, input logic [ID_WIDTH-1:0] m_axi_rid,
  input logic [DATA_WIDTH-1:0] m_axi_rdata, input logic [1:0] m_axi_rresp, input logic m_axi_rlast
);
  int rcnt;
  bit [2**ID_WIDTH-1:0] outstanding_arid_q;

  always @(posedge axi_aclk) begin
    if (!axi_aresetn) begin rcnt <= 0; outstanding_arid_q <= '0; end
    else begin
      rcnt <= (m_axi_rvalid && m_axi_rready) ? (m_axi_rlast ? 0 : rcnt + 1) : rcnt;
      if (m_axi_arvalid && m_axi_arready) outstanding_arid_q[m_axi_arid] <= 1'b1;
      if (m_axi_rvalid && m_axi_rready && m_axi_rlast) outstanding_arid_q[m_axi_rid] <= 1'b0;
    end
  end

  property p_m_axi_arvalid_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_arvalid && !m_axi_arready |=> m_axi_arvalid;
  endproperty
  a_m_axi_arvalid_stable: assert property(p_m_axi_arvalid_stable) else $error("MRD-ASSERT-01 FAIL");

  property p_m_axi_ar_araddr_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn) (m_axi_arvalid && !m_axi_arready) |=> $stable(m_axi_araddr);
  endproperty
  a_m_axi_ar_araddr_stable: assert property(p_m_axi_ar_araddr_stable) else $error("MRD-ASSERT-02 FAIL");

  property p_m_axi_rlast_count;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    (m_axi_rvalid && m_axi_rready && m_axi_rlast) |-> (rcnt == m_axi_arlen);
  endproperty
  a_m_axi_rlast_count: assert property(p_m_axi_rlast_count) else $error("MRD-ASSERT-03 FAIL");

  property p_m_axi_r_stable;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    (m_axi_rvalid && !m_axi_rready) |=> $stable({m_axi_rid, m_axi_rdata, m_axi_rresp});
  endproperty
  a_m_axi_r_stable: assert property(p_m_axi_r_stable) else $error("MRD-ASSERT-04 FAIL");

  property p_m_axi_rid_legal;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_rvalid |-> outstanding_arid_q[m_axi_rid];
  endproperty
  a_m_axi_rid_legal: assert property(p_m_axi_rid_legal) else $error("MRD-ASSERT-05 FAIL");

  property p_m_axi_ar_addr_no_x;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_arvalid |-> !$isunknown(m_axi_araddr);
  endproperty
  a_m_axi_ar_addr_no_x: assert property(p_m_axi_ar_addr_no_x) else $error("MRD-ASSERT-06 FAIL");

  property p_m_axi_arsize_legal;
    @(posedge axi_aclk) disable iff (!axi_aresetn) m_axi_arvalid |-> (m_axi_arsize <= $clog2(DATA_WIDTH/8));
  endproperty
  a_m_axi_arsize_legal: assert property(p_m_axi_arsize_legal) else $error("MRD-ASSERT-07 FAIL");
endmodule : axi_master_read_sva
