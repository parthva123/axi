class axi_bridge_arb_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_arb_test)
  int unsigned num_concurrent_iters = 15;

  function new(string name = "axi_bridge_arb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_bridge_desc_dma_vseq wr_vseq, rd_vseq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running arbitration stress test");
    repeat (num_concurrent_iters) begin
      wr_vseq = axi_bridge_desc_dma_vseq::type_id::create("wr_vseq"); wr_vseq.cfg = cfg;
      rd_vseq = axi_bridge_desc_dma_vseq::type_id::create("rd_vseq"); rd_vseq.cfg = cfg;
      if (!wr_vseq.randomize() with { txn_type == 0; }) `uvm_fatal(get_type_name(), "wr_vseq randomize failed")
      if (!rd_vseq.randomize() with { txn_type == 1; }) `uvm_fatal(get_type_name(), "rd_vseq randomize failed")
      fork
        wr_vseq.start(env.vseqr);
        rd_vseq.start(env.vseqr);
      join
    end
    phase.drop_objection(this, "Arbitration stress test complete");
  endtask
endclass : axi_bridge_arb_test
