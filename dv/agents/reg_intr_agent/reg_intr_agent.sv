class reg_intr_agent extends uvm_agent;
  `uvm_component_utils(reg_intr_agent)

  reg_intr_agent_cfg cfg;
  reg_intr_driver     driver;
  reg_intr_monitor    monitor;
  reg_intr_sequencer  sequencer;

  function new(string name = "reg_intr_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(reg_intr_agent_cfg)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get reg_intr_agent_cfg")

    monitor = reg_intr_monitor::type_id::create("monitor", this);
    uvm_config_db#(virtual reg_intr_if)::set(this, "monitor", "vif", cfg.vif);

    if (cfg.is_active == UVM_ACTIVE) begin
      driver    = reg_intr_driver::type_id::create("driver", this);
      sequencer = reg_intr_sequencer::type_id::create("sequencer", this);
      uvm_config_db#(virtual reg_intr_if)::set(this, "driver", "vif", cfg.vif);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass : reg_intr_agent
