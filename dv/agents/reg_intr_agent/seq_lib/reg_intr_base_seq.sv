class reg_intr_base_seq extends uvm_sequence #(reg_intr_seq_item);
  `uvm_object_utils(reg_intr_base_seq)

  function new(string name = "reg_intr_base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "override body() in derived seq", UVM_LOW)
  endtask
endclass : reg_intr_base_seq
