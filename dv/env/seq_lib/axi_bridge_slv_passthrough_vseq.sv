class axi_bridge_slv_passthrough_vseq extends axi_bridge_base_vseq;
  `uvm_object_utils(axi_bridge_slv_passthrough_vseq)

  rand int unsigned num_txns = 10;

  function new(string name = "axi_bridge_slv_passthrough_vseq");
    super.new(name);
  endfunction

  // SLV-TC-01/02: drive real AXI4 write/read bursts on S_AXI_USR and let
  // the scoreboard's M_AXI-side monitor confirm each one reappears on
  // M_AXI (SLV-ASSERT-01 in axi_slave_bridge_sva.sv checks the same thing
  // at the whitebox level once its bind is resolved).
  task body();
    axi_rand_write_seq wr_seq;

    `uvm_info(get_type_name(), "Starting S_AXI_USR -> M_AXI passthrough vseq", UVM_LOW)
    wr_seq = axi_rand_write_seq::type_id::create("wr_seq");
    wr_seq.num_txns = num_txns;
    wr_seq.start(p_sequencer.s_axi_usr_sqr);
    `uvm_info(get_type_name(), "Passthrough vseq complete", UVM_LOW)
  endtask
endclass : axi_bridge_slv_passthrough_vseq
