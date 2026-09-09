class axi_bridge_irq_cov_subscriber extends uvm_subscriber #(reg_intr_seq_item);
  `uvm_component_utils(axi_bridge_irq_cov_subscriber)

  axi_bridge_env_cov cov;
  axi_bridge_env_cfg cfg;

  function new(string name = "axi_bridge_irq_cov_subscriber", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(reg_intr_seq_item t);
    if (cov != null && cfg != null) cov.write_system_event(cfg.protocol);
  endfunction
endclass : axi_bridge_irq_cov_subscriber
