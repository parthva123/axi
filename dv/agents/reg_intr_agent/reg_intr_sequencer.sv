class reg_intr_sequencer extends uvm_sequencer #(reg_intr_seq_item);
  `uvm_component_utils(reg_intr_sequencer)
  reg_intr_agent_cfg cfg;

  function new(string name = "reg_intr_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass : reg_intr_sequencer
