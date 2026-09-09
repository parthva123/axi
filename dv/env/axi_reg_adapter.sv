class axi_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(axi_reg_adapter)

  function new(string name = "axi_reg_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses    = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    axi_seq_item item = axi_seq_item::type_id::create("reg2bus_item");
    item.addr  = rw.addr;
    item.len   = 0;
    item.size  = 3'b010;
    item.burst = axi_seq_item::AXI_INCR;

    if (rw.kind == UVM_WRITE) begin
      item.dir = axi_seq_item::WRITE_TXN;
      item.wdata.push_back(rw.data);
      item.wstrb.push_back(16'h000F);
    end else begin
      item.dir = axi_seq_item::READ_TXN;
    end
    return item;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    axi_seq_item item;
    if (!$cast(item, bus_item))
      `uvm_fatal(get_type_name(), "bus2reg: failed to cast to axi_seq_item")

    rw.kind   = (item.dir == axi_seq_item::WRITE_TXN) ? UVM_WRITE : UVM_READ;
    rw.addr   = item.addr;
    rw.status = (item.resp == axi_seq_item::RESP_OKAY) ? UVM_IS_OK : UVM_NOT_OK;

    if (item.dir == axi_seq_item::READ_TXN && item.rdata.size() > 0)
      rw.data = item.rdata[0][31:0];
    else if (item.wdata.size() > 0)
      rw.data = item.wdata[0][31:0];
  endfunction
endclass : axi_reg_adapter
