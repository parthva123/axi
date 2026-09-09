class axi_bridge_smoke_vseq extends axi_bridge_base_vseq;
  `uvm_object_utils(axi_bridge_smoke_vseq)

  function new(string name = "axi_bridge_smoke_vseq");
    super.new(name);
  endfunction

  task body();
    axi_rand_write_seq wr_seq;
    `uvm_info(get_type_name(), "Starting smoke vseq", UVM_LOW)
    wr_seq = axi_rand_write_seq::type_id::create("wr_seq");
    wr_seq.num_txns = 5;
    // FIXED: burst-capable random writes belong on S_AXI_USR (real AXI4
    // data-plane port), not S_AXI (AXI4-Lite config port, which has no
    // burst semantics - awlen must always be 0 there).
    wr_seq.start(p_sequencer.s_axi_usr_sqr);
    `uvm_info(get_type_name(), "Smoke vseq complete", UVM_LOW)
  endtask
endclass : axi_bridge_smoke_vseq
