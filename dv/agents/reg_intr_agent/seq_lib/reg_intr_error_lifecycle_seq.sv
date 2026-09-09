class reg_intr_error_lifecycle_seq extends reg_intr_base_seq;
  `uvm_object_utils(reg_intr_error_lifecycle_seq)

  function new(string name = "reg_intr_error_lifecycle_seq");
    super.new(name);
  endfunction

  task body();
    reg_intr_seq_item item;

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op    = reg_intr_seq_item::REG_WRITE;
    item.addr  = `INTR_ERROR_ENABLE_REG_ADDR;   // from axi_bridge_reg_defs.sv - single source of truth
    item.wdata = 32'hFFFF_FFFF;
    finish_item(item);

    #100ns;

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op   = reg_intr_seq_item::REG_READ;
    item.addr = `INTR_ERROR_STATUS_REG_ADDR;
    finish_item(item);
    `uvm_info(get_type_name(),
      $sformatf("intr_error_status_reg = 0x%0h", item.rdata), UVM_LOW)

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op    = reg_intr_seq_item::REG_WRITE;
    item.addr  = `INTR_ERROR_CLEAR_REG_ADDR;
    item.wdata = 32'hFFFF_FFFF;
    finish_item(item);

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op   = reg_intr_seq_item::REG_READ;
    item.addr = `INTR_ERROR_STATUS_REG_ADDR;
    finish_item(item);
    if (item.rdata != 32'h0)
      `uvm_error(get_type_name(),
        $sformatf("REG-ASSERT-04 FAIL: intr_error_status_reg not cleared, still 0x%0h", item.rdata))
    else
      `uvm_info(get_type_name(), "intr_error_status_reg cleared OK", UVM_LOW)
  endtask
endclass : reg_intr_error_lifecycle_seq
