class axi_bridge_ral_smoke_vseq extends axi_bridge_base_vseq;
  `uvm_object_utils(axi_bridge_ral_smoke_vseq)

  function new(string name = "axi_bridge_ral_smoke_vseq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e   status;
    uvm_reg_data_t rdata;

    cfg.ral.version_reg.read(status, rdata, .parent(this));
    `uvm_info(get_type_name(), $sformatf("version_reg = 0x%0h (status=%s)", rdata, status.name()), UVM_LOW)

    cfg.ral.axi_max_desc_reg.read(status, rdata, .parent(this));
    if (rdata != cfg.max_desc)
      `uvm_error(get_type_name(),
        $sformatf("REG-TC-12 FAIL: axi_max_desc_reg=%0d != cfg.max_desc=%0d", rdata, cfg.max_desc))
    else
      `uvm_info(get_type_name(), "REG-TC-12 PASS: axi_max_desc_reg matches MAX_DESC", UVM_LOW)

    cfg.ral.desc[3].txn_type.write(status, 32'h1, .parent(this));
    cfg.ral.desc[3].txn_type.read(status, rdata, .parent(this));
    if (rdata != 32'h1)
      `uvm_error(get_type_name(), $sformatf("desc[3].txn_type readback mismatch: 0x%0h", rdata))
    else
      `uvm_info(get_type_name(), "desc[3].txn_type readback OK", UVM_LOW)

    `uvm_info(get_type_name(), "RAL smoke vseq complete", UVM_LOW)
  endtask
endclass : axi_bridge_ral_smoke_vseq
