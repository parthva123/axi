class axi_agent #(
  int ADDR_WIDTH = 64,
  int DATA_WIDTH = 128,
  int ID_WIDTH   = 4,
  int USER_WIDTH = 32
) extends uvm_agent;

  `uvm_component_param_utils(axi_agent#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH))

  typedef axi_agent_cfg#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH) cfg_t;
  typedef axi_driver#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH)    driver_t;
  typedef axi_monitor#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH)   monitor_t;
  typedef axi_sequencer#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH) sequencer_t;

  cfg_t       cfg;
  driver_t    driver;
  monitor_t   monitor;
  sequencer_t sequencer;

  function new(string name = "axi_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(cfg_t)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get axi_agent_cfg in axi_agent")

    monitor = monitor_t::type_id::create("monitor", this);
    uvm_config_db#(cfg_t)::set(this, "monitor", "cfg", cfg);

    if (cfg.is_active == UVM_ACTIVE) begin
      driver    = driver_t::type_id::create("driver", this);
      sequencer = sequencer_t::type_id::create("sequencer", this);
      uvm_config_db#(cfg_t)::set(this, "driver", "cfg", cfg);
      sequencer.cfg = cfg;
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : axi_agent

// Concrete typedefs used by the env - one for S_AXI_USR (driven), one for
// M_AXI (passively monitored). This is the actual fix for the vif clash:
// each now carries its own DATA_WIDTH baked into the type.
typedef axi_agent#(.ADDR_WIDTH(64), .DATA_WIDTH(32),  .ID_WIDTH(4), .USER_WIDTH(32)) s_axi_cfg_agent_t;
typedef axi_agent#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) m_axi_agent_t;
typedef axi_agent#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) s_axi_usr_agent_t;
