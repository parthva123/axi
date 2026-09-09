interface reg_intr_if (
  input logic clk,
  input logic rst_n
);
  logic         irq_out;
  logic         irq_ack;
  logic [255:0] h2c_gpio_out;
  logic [255:0] c2h_gpio_in;
  logic [63:0]  h2c_pulse_out;      // FIXED: widened from [1:0] to real RTL width [63:0]
  logic [127:0] h2c_intr_out;       // ADDED: real RTL port, was dangling in tb.sv before
  logic [63:0]  c2h_intr_in;        // ADDED: real RTL port, was dangling in tb.sv before

  logic [3:0]   gnt_idx_tap;
  logic         gnt_vld_tap;
  logic [15:0]  node_busy_tap;

  clocking cb @(posedge clk);
    output c2h_gpio_in, irq_ack, c2h_intr_in;
    input  irq_out, h2c_gpio_out, h2c_pulse_out, h2c_intr_out;
    input  gnt_idx_tap, gnt_vld_tap, node_busy_tap;
  endclocking

  modport driver (clocking cb, input clk, rst_n);
endinterface : reg_intr_if
