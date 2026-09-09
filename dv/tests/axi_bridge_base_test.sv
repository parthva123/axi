class axi_bridge_base_test extends uvm_test;
  `uvm_component_utils(axi_bridge_base_test)

  axi_bridge_env     env;
  axi_bridge_env_cfg cfg;

  function new(string name = "axi_bridge_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg = axi_bridge_env_cfg::type_id::create("cfg");
    cfg.initialize();

    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "clk_rst_vif", cfg.clk_rst_vif))
      `uvm_fatal(get_type_name(), "Failed to get clk_rst_vif")

    // FIXED: primary vif assignment path - grabs the parameterized virtual
    // interfaces straight from config_db using the SAME parameterized
    // type the tb.sv set() calls used, then assigns them onto cfg's
    // already-parameterized agent-cfg objects. This removes the earlier
    // ambiguity between "does vif get set here or in tb.sv".
    if (!uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(32),.ID_WIDTH(4),.USER_WIDTH(32)))::
          get(null, "*s_axi_cfg_agent*", "vif", cfg.s_axi_cfg_cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get S_AXI (config/RAL) vif")
    // ADDED: real S_AXI_USR data-plane vif (128b, 16-bit ID) - was missing
    // entirely from the original TB; this is the port that actually
    // carries real bridged traffic.
    if (!uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(128),.ID_WIDTH(16),.USER_WIDTH(32)))::
          get(null, "*s_axi_usr_agent*", "vif", cfg.s_axi_usr_cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get S_AXI_USR vif")
    if (!uvm_config_db#(virtual axi_if#(.ADDR_WIDTH(64),.DATA_WIDTH(128),.ID_WIDTH(16),.USER_WIDTH(32)))::
          get(null, "*m_axi_mon_agent*", "vif", cfg.m_axi_mon_cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get M_AXI vif")
    if (!uvm_config_db#(virtual reg_intr_if)::get(null, "*reg_intr_agt*", "vif", cfg.reg_intr_cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get reg_intr_if vif")

    uvm_config_db#(axi_bridge_env_cfg)::set(this, "env", "cfg", cfg);
    env = axi_bridge_env::type_id::create("env", this);

    process_plusargs();
  endfunction

  function void process_plusargs();
    int unsigned max_desc_ovr;
    if ($value$plusargs("MAX_DESC=%d", max_desc_ovr)) cfg.max_desc = max_desc_ovr;
    if ($test$plusargs("EXTEND_WSTRB")) cfg.extend_wstrb = 1;
    if ($test$plusargs("FORCE_RESP_ORDER_OFF")) cfg.force_resp_order = 0;
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Applying initial reset");
    cfg.clk_rst_vif.apply_reset();
    phase.drop_objection(this, "Initial reset complete");
  endtask

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0)
      `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE)
    else
      `uvm_info(get_type_name(), "TEST FAILED", UVM_NONE)
  endfunction
endclass : axi_bridge_base_test
