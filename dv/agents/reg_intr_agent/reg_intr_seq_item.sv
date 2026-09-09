class reg_intr_seq_item extends uvm_sequence_item;
  typedef enum { REG_WRITE, REG_READ, GPIO_DRIVE, INTR_ACK } op_e;

  rand op_e        op;
  rand bit [31:0]  addr;
  rand bit [31:0]  wdata;
  bit  [31:0]      rdata;
  rand bit [255:0] c2h_gpio_drive;
  rand bit         irq_ack;

  constraint c_addr_word_aligned { addr[1:0] == 2'b00; }

  `uvm_object_utils_begin(reg_intr_seq_item)
    `uvm_field_enum(op_e, op, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_field_int(c2h_gpio_drive, UVM_ALL_ON)
    `uvm_field_int(irq_ack, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "reg_intr_seq_item");
    super.new(name);
  endfunction
endclass : reg_intr_seq_item
