class axi_bridge_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_bridge_virtual_sequencer)

  s_axi_cfg_sequencer_t s_axi_cfg_sqr;   // 32b AXI4-Lite - register/descriptor config
  s_axi_usr_sequencer_t s_axi_usr_sqr;   // ADDED: 128b AXI4 - real data-plane traffic
  reg_intr_sequencer     reg_intr_sqr;
  axi_bridge_env_cfg     cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass : axi_bridge_virtual_sequencer
