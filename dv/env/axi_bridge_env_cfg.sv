class axi_bridge_env_cfg extends uvm_object;
  `uvm_object_utils(axi_bridge_env_cfg)

  // FIXED: these now use the parameterized typedefs (s_axi_cfg_agent_cfg_t /
  // m_axi_agent_cfg_t) instead of the plain non-parameterized axi_agent_cfg,
  // which is the root fix for the vif width mismatch reported earlier.
  s_axi_cfg_agent_cfg_t s_axi_cfg_cfg;    // 32b AXI4-Lite, ACTIVE - register/descriptor config (real RTL: s_axi_*)
  s_axi_usr_agent_cfg_t s_axi_usr_cfg;    // 128b AXI4, ACTIVE - real data-plane slave port (real RTL: s_axi_usr_*)
  m_axi_agent_cfg_t      m_axi_mon_cfg;   // 128b AXI4, PASSIVE - bridged master output, monitored only
  reg_intr_agent_cfg     reg_intr_cfg;

  axi_bridge_ral_pkg::axi_bridge_reg_block ral;
  axi_reg_adapter                          reg_adapter;

  virtual clk_rst_if clk_rst_vif;

  axi_protocol_e protocol            = AXI_PROTO_AXI4;
  int unsigned   max_desc            = `AXI_BRIDGE_MAX_DESC;
  int unsigned   ram_size            = RAM_SIZE;
  bit            extend_wstrb        = 0;
  bit            force_resp_order    = 1;
  int unsigned   usr_rst_num         = 4;

  bit en_scb  = 1;
  bit en_cov  = 1;
  bit en_async_reset_injection = 0;

  int unsigned aw_ready_delay_min = 0;
  int unsigned aw_ready_delay_max = 5;
  int unsigned w_ready_delay_min  = 0;
  int unsigned w_ready_delay_max  = 5;
  int unsigned b_ready_delay_min  = 0;
  int unsigned b_ready_delay_max  = 3;

  function new(string name = "axi_bridge_env_cfg");
    super.new(name);
  endfunction

  function void initialize();
    s_axi_cfg_cfg = s_axi_cfg_agent_cfg_t::type_id::create("s_axi_cfg_cfg");
    s_axi_cfg_cfg.is_active = UVM_ACTIVE;

    s_axi_usr_cfg = s_axi_usr_agent_cfg_t::type_id::create("s_axi_usr_cfg");
    s_axi_usr_cfg.is_active = UVM_ACTIVE;

    m_axi_mon_cfg = m_axi_agent_cfg_t::type_id::create("m_axi_mon_cfg");
    m_axi_mon_cfg.is_active = UVM_PASSIVE;

    reg_intr_cfg = reg_intr_agent_cfg::type_id::create("reg_intr_cfg");
    reg_intr_cfg.is_active = UVM_ACTIVE;

    ral = axi_bridge_ral_pkg::axi_bridge_reg_block::type_id::create("ral");
    ral.build();

    reg_adapter = axi_reg_adapter::type_id::create("reg_adapter");
  endfunction
endclass : axi_bridge_env_cfg
