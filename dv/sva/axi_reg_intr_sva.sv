module axi_reg_intr_sva #(
  parameter int NUM_ERR_BITS = 32, parameter int NUM_GPIO_BITS = 32
) (
  input logic axi_aclk, input logic axi_aresetn,
  input logic [31:0] version_reg, input logic irq_out, input logic irq_ack,
  input logic [NUM_GPIO_BITS-1:0] c2h_gpio_in_x, input logic [NUM_GPIO_BITS-1:0] c2h_gpio_x_status_reg,
  input logic [NUM_ERR_BITS-1:0] intr_error_clear_reg, input logic [NUM_ERR_BITS-1:0] intr_error_status_reg,
  input logic [31:0] mode_select__reg, input logic mode_select_valid
);
  property p_version_reg_readonly;
    @(posedge axi_aclk) disable iff (!axi_aresetn) $stable(version_reg);
  endproperty
  a_version_reg_readonly: assert property(p_version_reg_readonly) else $error("REG-ASSERT-01 FAIL");

  property p_irq_ack_clears;
    @(posedge axi_aclk) disable iff (!axi_aresetn) irq_out && !irq_ack |=> irq_out;
  endproperty
  a_irq_ack_clears: assert property(p_irq_ack_clears) else $error("REG-ASSERT-02 FAIL");

  property p_gpio_status_mirror;
    @(posedge axi_aclk) disable iff (!axi_aresetn)
    c2h_gpio_in_x |=> (c2h_gpio_x_status_reg == $past(c2h_gpio_in_x));
  endproperty
  a_gpio_status_mirror: assert property(p_gpio_status_mirror) else $error("REG-ASSERT-03 FAIL");

  genvar gi;
  generate
    for (gi = 0; gi < NUM_ERR_BITS; gi++) begin : gen_err_clear
      property p_err_clear;
        @(posedge axi_aclk) disable iff (!axi_aresetn)
        (intr_error_clear_reg[gi] && intr_error_status_reg[gi]) |=> !intr_error_status_reg[gi];
      endproperty
      a_err_clear: assert property(p_err_clear) else $error("REG-ASSERT-04 FAIL[%0d]", gi);
    end
  endgenerate

  property p_mode_select__reg_no_x;
    @(posedge axi_aclk) disable iff (!axi_aresetn) mode_select_valid |-> !$isunknown(mode_select__reg);
  endproperty
  a_mode_select__reg_no_x: assert property(p_mode_select__reg_no_x) else $error("REG-ASSERT-05 FAIL");
endmodule : axi_reg_intr_sva
