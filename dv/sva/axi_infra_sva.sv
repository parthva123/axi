module axi_infra_sva #(parameter int MAX_DESC = 16) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic fifo_full, input logic fifo_empty, input logic fifo_wr_en, input logic fifo_rd_en,
  input logic dst_clk, input logic dst_rst_n, input logic sync_out,
  input logic axid_lookup_hit, input logic [3:0] axid_lookup_id, input logic [MAX_DESC-1:0] stored_id_valid_q
);
  property p_fifo_full_empty_excl;
    @(posedge axi_aclk) disable iff (!axi_aresetn) !(fifo_full && fifo_empty);
  endproperty
  a_fifo_full_empty_excl: assert property(p_fifo_full_empty_excl) else $error("INFRA-ASSERT-01 FAIL");

  property p_fifo_no_overflow;
    @(posedge axi_aclk) disable iff (!axi_aresetn) fifo_full |-> !fifo_wr_en;
  endproperty
  a_fifo_no_overflow: assert property(p_fifo_no_overflow) else $error("INFRA-ASSERT-02 FAIL");

  property p_fifo_no_underflow;
    @(posedge axi_aclk) disable iff (!axi_aresetn) fifo_empty |-> !fifo_rd_en;
  endproperty
  a_fifo_no_underflow: assert property(p_fifo_no_underflow) else $error("INFRA-ASSERT-03 FAIL");

  property p_sync_no_glitch;
    @(posedge dst_clk) disable iff (!dst_rst_n) $changed(sync_out) |-> $stable(sync_out) [*2];
  endproperty
  a_sync_no_glitch: assert property(p_sync_no_glitch) else $error("INFRA-ASSERT-04 FAIL");

  property p_axid_store_no_phantom_hit;
    @(posedge axi_aclk) disable iff (!axi_aresetn) axid_lookup_hit |-> stored_id_valid_q[axid_lookup_id];
  endproperty
  a_axid_store_no_phantom_hit: assert property(p_axid_store_no_phantom_hit) else $error("INFRA-ASSERT-05 FAIL");
endmodule : axi_infra_sva
