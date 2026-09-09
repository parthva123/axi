class axi_sequencer #(
  int ADDR_WIDTH = 64,
  int DATA_WIDTH = 128,
  int ID_WIDTH   = 4,
  int USER_WIDTH = 32
) extends uvm_sequencer #(axi_seq_item);

  `uvm_component_param_utils(axi_sequencer#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH))

  typedef axi_agent_cfg#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH) cfg_t;
  cfg_t cfg;

  function new(string name = "axi_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : axi_sequencer

// Concrete typedefs matching axi_agent_cfg's typedefs above.
typedef axi_sequencer#(.ADDR_WIDTH(64), .DATA_WIDTH(32),  .ID_WIDTH(4), .USER_WIDTH(32)) s_axi_cfg_sequencer_t;
typedef axi_sequencer#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) m_axi_sequencer_t;
typedef axi_sequencer#(.ADDR_WIDTH(64), .DATA_WIDTH(128), .ID_WIDTH(16), .USER_WIDTH(32)) s_axi_usr_sequencer_t;
