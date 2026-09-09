class axi_bridge_desc_dma_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_desc_dma_test)
  int unsigned num_desc_iters = 20;

  function new(string name = "axi_bridge_desc_dma_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void process_plusargs();
    int unsigned iters_ovr;
    super.process_plusargs();
    if ($value$plusargs("NUM_DESC_ITERS=%d", iters_ovr)) num_desc_iters = iters_ovr;
  endfunction

  task run_phase(uvm_phase phase);
    axi_bridge_desc_dma_vseq vseq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running descriptor DMA vseq");
    repeat (num_desc_iters) begin
      vseq = axi_bridge_desc_dma_vseq::type_id::create("vseq");
      vseq.cfg = cfg;
      if (!vseq.randomize()) `uvm_fatal(get_type_name(), "vseq randomization failed")
      vseq.start(env.vseqr);
    end
    phase.drop_objection(this, "Descriptor DMA vseq complete");
  endtask
endclass : axi_bridge_desc_dma_test
