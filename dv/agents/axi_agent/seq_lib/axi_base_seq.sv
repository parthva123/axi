class axi_base_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_base_seq)

  function new(string name = "axi_base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "override body() in derived seq", UVM_LOW)
  endtask
endclass : axi_base_seq
