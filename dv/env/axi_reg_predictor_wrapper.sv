// FIXED: predictor is parameterized to the S_AXI_USR (32b) axi_seq_item
// stream only - it must sit on the same bus as the driver it predicts
// for, matching the s_axi_cfg_agent_t typedef used everywhere else.
typedef uvm_reg_predictor #(axi_seq_item) axi_reg_predictor_t;
