class reg_intr_agent_cfg extends uvm_object;
  `uvm_object_utils(reg_intr_agent_cfg)

  virtual reg_intr_if vif;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "reg_intr_agent_cfg");
    super.new(name);
  endfunction
endclass : reg_intr_agent_cfg
