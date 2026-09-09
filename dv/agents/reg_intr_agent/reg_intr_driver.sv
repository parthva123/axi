class reg_intr_driver extends uvm_driver #(reg_intr_seq_item);
  `uvm_component_utils(reg_intr_driver)

  virtual reg_intr_if  vif;
  s_axi_cfg_sequencer_t axi_reg_sqr;   // FIXED: typed to the S_AXI_USR (32b) sequencer

  function new(string name = "reg_intr_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reg_intr_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Failed to get reg_intr_if")
  endfunction

  task run_phase(uvm_phase phase);
    vif.cb.c2h_gpio_in <= '0;
    vif.cb.irq_ack     <= 1'b0;
    vif.cb.c2h_intr_in <= '0;   // ADDED: was left undriven (X) since it's now a real output
    @(posedge vif.rst_n);

    forever begin
      seq_item_port.get_next_item(req);
      case (req.op)
        reg_intr_seq_item::REG_WRITE:  do_reg_write(req);
        reg_intr_seq_item::REG_READ:   do_reg_read(req);
        reg_intr_seq_item::GPIO_DRIVE: do_gpio_drive(req);
        reg_intr_seq_item::INTR_ACK:   do_intr_ack(req);
      endcase
      seq_item_port.item_done();
    end
  endtask

  task do_reg_write(reg_intr_seq_item item);
    axi_seq_item axi_item;
    axi_item = axi_seq_item::type_id::create("reg_wr_axi_item");
    axi_item.dir   = axi_seq_item::WRITE_TXN;
    axi_item.addr  = item.addr;
    axi_item.len   = 0;
    axi_item.size  = 3'b010;
    axi_item.burst = axi_seq_item::AXI_INCR;
    axi_item.wdata.push_back(item.wdata);
    axi_item.wstrb.push_back(16'h000F);
    axi_reg_sqr.execute_item(axi_item);
    `uvm_info(get_type_name(),
      $sformatf("REG_WRITE addr=0x%0h data=0x%0h", item.addr, item.wdata), UVM_MEDIUM)
  endtask

  task do_reg_read(reg_intr_seq_item item);
    axi_seq_item axi_item;
    axi_item = axi_seq_item::type_id::create("reg_rd_axi_item");
    axi_item.dir   = axi_seq_item::READ_TXN;
    axi_item.addr  = item.addr;
    axi_item.len   = 0;
    axi_item.size  = 3'b010;
    axi_item.burst = axi_seq_item::AXI_INCR;
    axi_reg_sqr.execute_item(axi_item);
    if (axi_item.rdata.size() > 0)
      item.rdata = axi_item.rdata[0][31:0];
    `uvm_info(get_type_name(),
      $sformatf("REG_READ addr=0x%0h data=0x%0h", item.addr, item.rdata), UVM_MEDIUM)
  endtask

  task do_gpio_drive(reg_intr_seq_item item);
    vif.cb.c2h_gpio_in <= item.c2h_gpio_drive;
    @(vif.cb);
    `uvm_info(get_type_name(),
      $sformatf("GPIO_DRIVE c2h_gpio_in=0x%0h", item.c2h_gpio_drive), UVM_MEDIUM)
  endtask

  task do_intr_ack(reg_intr_seq_item item);
    vif.cb.irq_ack <= item.irq_ack;
    @(vif.cb);
    if (item.irq_ack) begin
      @(vif.cb);
      vif.cb.irq_ack <= 1'b0;
    end
  endtask
endclass : reg_intr_driver
