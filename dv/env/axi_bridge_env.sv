class axi_bridge_env extends uvm_env;
  `uvm_component_utils(axi_bridge_env)

  axi_bridge_env_cfg cfg;
  axi_bridge_env_cov cov;
  axi_bridge_scoreboard scoreboard;
  axi_bridge_virtual_sequencer vseqr;

  // FIXED: these now use the concrete parameterized typedefs so the
  // 32-bit S_AXI_USR vif and the 128-bit M_AXI vif no longer collide.
  s_axi_cfg_agent_t s_axi_cfg_agent;   // 32b AXI4-Lite, ACTIVE - RAL register/descriptor programming
  s_axi_usr_agent_t s_axi_usr_agent;   // ADDED: 128b AXI4, ACTIVE - real data-plane slave port
  m_axi_agent_t     m_axi_mon_agent;   // 128b AXI4, PASSIVE - bridged output, now backed by m_axi_mem_model
  reg_intr_agent    reg_intr_agt;
  axi_bridge_irq_cov_subscriber irq_cov_sub;

  axi_reg_predictor_t reg_predictor;

  function new(string name = "axi_bridge_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(axi_bridge_env_cfg)::get(this, "", "cfg", cfg)) begin
      cfg = axi_bridge_env_cfg::type_id::create("cfg");
      cfg.initialize();
    end
    uvm_config_db#(axi_bridge_env_cfg)::set(this, "*", "cfg", cfg);

    if (cfg.en_cov) begin
      cov = axi_bridge_env_cov::type_id::create("cov", this);
      irq_cov_sub = axi_bridge_irq_cov_subscriber::type_id::create("irq_cov_sub", this);
      irq_cov_sub.cov = cov;
      irq_cov_sub.cfg = cfg;
    end

    if (cfg.en_scb) begin
      scoreboard = axi_bridge_scoreboard::type_id::create("scoreboard", this);
      scoreboard.cfg = cfg;
      scoreboard.cov = cov;
      // FIXED: expose the scoreboard on cfg so virtual sequences (e.g.
      // axi_bridge_desc_dma_vseq) can call predict_desc_txn() without a
      // separate config_db round-trip.
      cfg.set_scoreboard_handle(scoreboard);
    end

    vseqr = axi_bridge_virtual_sequencer::type_id::create("vseqr", this);
    vseqr.cfg = cfg;

    s_axi_cfg_agent = s_axi_cfg_agent_t::type_id::create("s_axi_cfg_agent", this);
    uvm_config_db#(s_axi_cfg_agent_cfg_t)::set(this, "s_axi_cfg_agent*", "cfg", cfg.s_axi_cfg_cfg);

    s_axi_usr_agent = s_axi_usr_agent_t::type_id::create("s_axi_usr_agent", this);
    uvm_config_db#(s_axi_usr_agent_cfg_t)::set(this, "s_axi_usr_agent*", "cfg", cfg.s_axi_usr_cfg);

    m_axi_mon_agent = m_axi_agent_t::type_id::create("m_axi_mon_agent", this);
    uvm_config_db#(m_axi_agent_cfg_t)::set(this, "m_axi_mon_agent*", "cfg", cfg.m_axi_mon_cfg);

    reg_intr_agt = reg_intr_agent::type_id::create("reg_intr_agt", this);
    uvm_config_db#(reg_intr_agent_cfg)::set(this, "reg_intr_agt*", "cfg", cfg.reg_intr_cfg);

    reg_predictor = axi_reg_predictor_t::type_id::create("reg_predictor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vseqr.s_axi_cfg_sqr = s_axi_cfg_agent.sequencer;
    vseqr.s_axi_usr_sqr = s_axi_usr_agent.sequencer;   // ADDED
    vseqr.reg_intr_sqr  = reg_intr_agt.sequencer;

    reg_intr_agt.driver.axi_reg_sqr = s_axi_cfg_agent.sequencer;
    if (cfg.en_cov) reg_intr_agt.monitor.cov = cov;   // FIXED: wires ARB-COV sampling

    cfg.ral.map.set_sequencer(s_axi_cfg_agent.sequencer, cfg.reg_adapter);
    reg_predictor.map     = cfg.ral.map;
    reg_predictor.adapter = cfg.reg_adapter;
    s_axi_cfg_agent.monitor.ap.connect(reg_predictor.bus_in);

    if (cfg.en_scb) begin
      // FIXED: monitor.ap now connects straight to m_axi_fifo's analysis
      // export - this is the actual bug fix for the dead scoreboard.
      m_axi_mon_agent.monitor.ap.connect(scoreboard.m_axi_fifo.analysis_export);
    end

    if (cfg.en_cov)
      reg_intr_agt.monitor.irq_ap.connect(irq_cov_sub.analysis_export);
  endfunction
endclass : axi_bridge_env
