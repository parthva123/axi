class reg_intr_monitor extends uvm_monitor;
  `uvm_component_utils(reg_intr_monitor)

  virtual reg_intr_if vif;
  axi_bridge_env_cov  cov;   // optional - set by env if coverage is enabled

  uvm_analysis_port #(reg_intr_seq_item) irq_ap;
  uvm_analysis_port #(reg_intr_seq_item) gpio_ap;
  uvm_analysis_port #(bit [4:0])         grant_ap;

  function new(string name = "reg_intr_monitor", uvm_component parent = null);
    super.new(name, parent);
    irq_ap   = new("irq_ap", this);
    gpio_ap  = new("gpio_ap", this);
    grant_ap = new("grant_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reg_intr_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Failed to get reg_intr_if")
  endfunction

  task run_phase(uvm_phase phase);
    fork
      mon_irq();
      mon_gpio();
      mon_grant();
    join
  endtask

  task mon_irq();
    bit prev_irq_out = 0;
    forever begin
      @(vif.cb);
      if (vif.cb.irq_out !== prev_irq_out) begin
        reg_intr_seq_item item = reg_intr_seq_item::type_id::create("irq_evt");
        item.op = reg_intr_seq_item::INTR_ACK;
        item.irq_ack = vif.cb.irq_out;
        irq_ap.write(item);
        prev_irq_out = vif.cb.irq_out;
      end
    end
  endtask

  task mon_gpio();
    bit [255:0] prev_gpio_out = 0;
    forever begin
      @(vif.cb);
      if (vif.cb.h2c_gpio_out !== prev_gpio_out) begin
        reg_intr_seq_item item = reg_intr_seq_item::type_id::create("gpio_evt");
        item.op = reg_intr_seq_item::GPIO_DRIVE;
        item.c2h_gpio_drive = vif.cb.h2c_gpio_out;
        gpio_ap.write(item);
        prev_gpio_out = vif.cb.h2c_gpio_out;
      end
    end
  endtask

  // FIXED: this task previously wrote to grant_ap only; ARB-COV was
  // never sampled anywhere in the codebase. Now also calls
  // cov.write_grant_event() directly so ARB-COV-* actually accumulates.
  task mon_grant();
    forever begin
      @(vif.cb);
      if (vif.cb.gnt_vld_tap) begin
        bit [4:0] payload = {vif.cb.gnt_vld_tap, vif.cb.gnt_idx_tap};
        grant_ap.write(payload);
        if (cov != null) cov.write_grant_event(vif.cb.gnt_idx_tap);
      end
    end
  endtask
endclass : reg_intr_monitor
