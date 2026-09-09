module axi_desc_dma_sva #(
  parameter int MAX_DESC = 16, parameter int RAM_SIZE = 16384, parameter int M_AXI_USR_DATA_W = 128
) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic [MAX_DESC-1:0] ownership_reg, input logic [MAX_DESC-1:0] txn_cmpl_q,
  input logic [MAX_DESC-1:0] h2c_pulse_out, input logic [MAX_DESC-1:0] uc2hm_trig, input logic [MAX_DESC-1:0] hm2uc_done,
  input logic uc2rb_wr_we, input logic [31:0] uc2rb_wr_addr,
  input logic [31:0] desc_0_txn_type__reg, input logic desc_0_txn_type_valid
);
  genvar gi;
  generate
    for (gi = 0; gi < MAX_DESC; gi++) begin : gen_own_flip
      property p_own_flip_after_cmpl;
        @(posedge axi_aclk) disable iff (!axi_aresetn) $rose(ownership_reg[gi]) |-> $past(txn_cmpl_q[gi]);
      endproperty
      a_own_flip_after_cmpl: assert property(p_own_flip_after_cmpl) else $error("DESC-ASSERT-01 FAIL[%0d]", gi);
    end
  endgenerate

  generate
    for (gi = 0; gi < MAX_DESC; gi++) begin : gen_pulse_width
      property p_h2c_pulse_width;
        @(posedge axi_aclk) disable iff (!axi_aresetn) $rose(h2c_pulse_out[gi]) |=> !h2c_pulse_out[gi];
      endproperty
      a_h2c_pulse_width: assert property(p_h2c_pulse_width) else $error("DESC-ASSERT-02 FAIL[%0d]", gi);
    end
  endgenerate

  generate
    for (gi = 0; gi < MAX_DESC; gi++) begin : gen_trig_done
      property p_trig_done_handshake;
        @(posedge axi_aclk) disable iff (!axi_aresetn)
        $rose(uc2hm_trig[gi]) |-> ##[1:$] hm2uc_done[gi] ##1 !uc2hm_trig[gi] until hm2uc_done[gi];
      endproperty
      a_trig_done_handshake: assert property(p_trig_done_handshake) else $error("DESC-ASSERT-03 FAIL[%0d]", gi);
    end
  endgenerate

  property p_ram_offset_bound;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    uc2rb_wr_we |-> (uc2rb_wr_addr < (RAM_SIZE * 8 / M_AXI_USR_DATA_W));
  endproperty
  a_ram_offset_bound: assert property(p_ram_offset_bound) else $error("DESC-ASSERT-04 FAIL");

  property p_desc_0_txn_type__reg_no_x;
    @(posedge axi_aclk) disable iff (!axi_aresetn) desc_0_txn_type_valid |-> !$isunknown(desc_0_txn_type__reg);
  endproperty
  a_desc_0_txn_type__reg_no_x: assert property(p_desc_0_txn_type__reg_no_x) else $error("DESC-ASSERT-05 FAIL");
endmodule : axi_desc_dma_sva
