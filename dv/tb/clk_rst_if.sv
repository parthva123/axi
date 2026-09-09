interface clk_rst_if (
  output logic clk,
  output logic rst_n
);
  real clk_period_ns = 10.0;
  bit  clk_en = 0;

  initial clk = 0;
  always #(clk_period_ns/2.0) if (clk_en) clk = ~clk;

  task automatic start_clk(real period_ns = 10.0);
    clk_period_ns = period_ns;
    clk_en = 1;
  endtask

  task automatic stop_clk();
    clk_en = 0;
  endtask

  task automatic apply_reset(int unsigned pre_cycles = 5, int unsigned hold_cycles = 10,
                              int unsigned post_cycles = 5);
    rst_n = 1'b1;
    repeat (pre_cycles) @(posedge clk);
    rst_n = 1'b0;
    $display("[%0t] clk_rst_if: asserting reset for %0d cycles", $time, hold_cycles);
    repeat (hold_cycles) @(posedge clk);
    rst_n = 1'b1;
    repeat (post_cycles) @(posedge clk);
    $display("[%0t] clk_rst_if: reset released", $time);
  endtask

  task automatic inject_async_reset(int unsigned assert_cycles = 3);
    rst_n = 1'b0;
    repeat (assert_cycles) @(posedge clk);
    rst_n = 1'b1;
  endtask

  function automatic real get_period_ns();
    return clk_period_ns;
  endfunction
endinterface : clk_rst_if
