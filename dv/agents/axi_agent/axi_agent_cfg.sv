class axi_agent_cfg #(
  int ADDR_WIDTH = 64,
  int DATA_WIDTH = 128,
  int ID_WIDTH   = 4,
  int USER_WIDTH = 32
) extends uvm_object;

  `uvm_object_param_utils(axi_agent_cfg#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH))

  virtual axi_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                    .ID_WIDTH(ID_WIDTH), .USER_WIDTH(USER_WIDTH)) vif;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  bit has_scoreboard = 1;
  bit en_cov         = 1;

  int unsigned aw_ready_delay_min = 0;
  int unsigned aw_ready_delay_max = 5;
  int unsigned w_ready_delay_min  = 0;
  int unsigned w_ready_delay_max  = 5;
  int unsigned b_ready_delay_min  = 0;
  int unsigned b_ready_delay_max  = 3;

  function new(string name = "axi_agent_cfg");
    super.new(name);
  endfunction

endclass : axi_agent_cfg

// Concrete typedefs used everywhere else in the env - avoids repeating
// the full parameter list at every point of use.
typedef axi_agent_cfg#(.ADDR_WIDTH(64), .DATA_WIDTH(32),  .ID_WIDTH(4), .USER_WIDTH(32)) s_axi_cfg_agent_cfg_t;
typedef axi_agent_cfg#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) m_axi_agent_cfg_t;
typedef axi_agent_cfg#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) s_axi_usr_agent_cfg_t;  // REAL data-plane slave port (ACTIVE)
