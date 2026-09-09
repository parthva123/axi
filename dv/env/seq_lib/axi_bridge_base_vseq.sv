class axi_bridge_base_vseq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(axi_bridge_base_vseq)
  `uvm_declare_p_sequencer(axi_bridge_virtual_sequencer)

  axi_bridge_env_cfg cfg;

  function new(string name = "axi_bridge_base_vseq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "override body() in derived vseq", UVM_LOW)
  endtask

  virtual task apply_reset();
    `uvm_info(get_type_name(), "Applying reset via clk_rst_if", UVM_LOW)
    cfg.clk_rst_vif.apply_reset();
  endtask
endclass : axi_bridge_base_vseq
