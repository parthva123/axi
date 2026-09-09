module axi_slave_bridge_sva #(
  parameter int ADDR_WIDTH = 64, parameter int MAX_DESC = 16
) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic s_axi_usr_awvalid, input logic s_axi_usr_awready, input logic [ADDR_WIDTH-1:0] s_axi_usr_awaddr,
  input logic m_axi_awvalid, input logic m_axi_awready, input logic [ADDR_WIDTH-1:0] m_axi_awaddr,
  input logic addr_alc_valid, input logic [3:0] addr_alc_node_idx,
  input logic [MAX_DESC-1:0] node_busy_q, input logic [MAX_DESC-1:0] txn_cmpl, input logic [3:0] node_q,
  input bit force_resp_order, input bit resp_valid, input int resp_idx, input int expected_fifo_order_idx,
  input bit axi4_active, input bit axi3_active, input bit axi4lite_active
);
  property p_slv_aw_passthrough;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    (s_axi_usr_awvalid && s_axi_usr_awready) |->
      ##[1:$] (m_axi_awvalid && m_axi_awready && m_axi_awaddr == $past(s_axi_usr_awaddr));
  endproperty
  a_slv_aw_passthrough: assert property(p_slv_aw_passthrough) else $error("SLV-ASSERT-01 FAIL");

  property p_addr_alc_no_double_alloc;
    @(posedge axi_aclk) disable iff (!axi_aresetn) addr_alc_valid |-> !node_busy_q[addr_alc_node_idx];
  endproperty
  a_addr_alc_no_double_alloc: assert property(p_addr_alc_no_double_alloc) else $error("SLV-ASSERT-02 FAIL");

  property p_addr_dealloc_match;
    @(posedge axi_aclk) disable iff (!axi_aresetn) txn_cmpl[node_q] |=> !node_busy_q[node_q];
  endproperty
  a_addr_dealloc_match: assert property(p_addr_dealloc_match) else $error("SLV-ASSERT-03 FAIL");

  property p_force_resp_order;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    (force_resp_order && resp_valid) |-> (resp_idx == expected_fifo_order_idx);
  endproperty
  a_force_resp_order: assert property(p_force_resp_order) else $error("SLV-ASSERT-04 FAIL");

  property p_s_axi_usr_aw_addr_no_x;
    @(posedge axi_aclk) disable iff (!axi_aresetn) s_axi_usr_awvalid |-> !$isunknown(s_axi_usr_awaddr);
  endproperty
  a_s_axi_usr_aw_addr_no_x: assert property(p_s_axi_usr_aw_addr_no_x) else $error("SLV-ASSERT-05 FAIL");

  property p_protocol_mux_exclusive;
    @(posedge axi_aclk) disable iff (!axi_aresetn) $onehot({axi4_active, axi3_active, axi4lite_active});
  endproperty
  a_protocol_mux_exclusive: assert property(p_protocol_mux_exclusive) else $error("SLV-ASSERT-06 FAIL");
endmodule : axi_slave_bridge_sva
