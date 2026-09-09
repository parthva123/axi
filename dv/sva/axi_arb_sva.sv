module axi_arb_sva #(parameter int MAX_DESC = 16) (
  input logic clk, input logic rst_n, input logic axi_aclk, input logic axi_aresetn,
  input logic [MAX_DESC-1:0] gnt_out, input logic gnt_vld, input logic [3:0] gnt_idx,
  input logic rd_alc_valid, input logic [MAX_DESC-1:0] int_status_busy_busy,
  input logic [1:0] ser_state, input logic rd_txn_valid
);
  typedef enum bit [1:0] {SER_IDLE=2'b00, SER_ALC=2'b01, SER_WAIT_DEALC=2'b10, SER_DEALC=2'b11} ser_state_e;

  property p_gnt_onehot;
    @(posedge clk) disable iff (!rst_n) $onehot0(gnt_out);
  endproperty
  a_gnt_onehot: assert property(p_gnt_onehot) else $error("ARB-ASSERT-01 FAIL");

  property p_gnt_idx_valid;
    @(posedge clk) disable iff (!rst_n) !gnt_vld |-> ($stable(gnt_idx) || gnt_idx == 0);
  endproperty
  a_gnt_idx_valid: assert property(p_gnt_idx_valid) else $error("ARB-ASSERT-02 FAIL");

  property p_alloc_needs_free_desc;
    @(posedge axi_aclk) disable iff (!axi_aresetn) rd_alc_valid |-> !(&int_status_busy_busy);
  endproperty
  a_alloc_needs_free_desc: assert property(p_alloc_needs_free_desc) else $error("ARB-ASSERT-03 FAIL");

  property p_addr_fsm_legal;
    @(posedge axi_aclk) disable iff (!axi_aresetn) ser_state inside {SER_IDLE, SER_ALC, SER_WAIT_DEALC, SER_DEALC};
  endproperty
  a_addr_fsm_legal: assert property(p_addr_fsm_legal) else $error("ARB-ASSERT-04 FAIL");

  property p_no_starvation;
    @(posedge axi_aclk) disable iff (!axi_aresetn) rd_txn_valid |-> ##[1:32] rd_alc_valid;
  endproperty
  a_no_starvation: assert property(p_no_starvation) else $error("ARB-ASSERT-05 FAIL");
endmodule : axi_arb_sva
