class axi_bridge_reg_intr_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_reg_intr_test)

  function new(string name = "axi_bridge_reg_intr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    reg_intr_gpio_toggle_seq     gpio_seq;
    reg_intr_error_lifecycle_seq err_seq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running reg/intr/gpio test");
    gpio_seq = reg_intr_gpio_toggle_seq::type_id::create("gpio_seq");
    if (!gpio_seq.randomize()) `uvm_fatal(get_type_name(), "gpio_seq randomization failed")
    gpio_seq.start(env.vseqr.reg_intr_sqr);
    err_seq = reg_intr_error_lifecycle_seq::type_id::create("err_seq");
    err_seq.start(env.vseqr.reg_intr_sqr);
    phase.drop_objection(this, "Reg/intr/gpio test complete");
  endtask
endclass : axi_bridge_reg_intr_test
