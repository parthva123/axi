class axi_bridge_infra_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_infra_test)

  function new(string name = "axi_bridge_infra_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_bridge_desc_dma_vseq vseq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running RAM/FIFO/CDC infra stress test");
    for (int i = 0; i < cfg.max_desc; i++) begin
      vseq = axi_bridge_desc_dma_vseq::type_id::create($sformatf("vseq_%0d", i));
      vseq.cfg = cfg;
      if (!vseq.randomize() with { desc_idx == local::i; }) `uvm_fatal(get_type_name(), "vseq randomize failed")
      fork
        automatic axi_bridge_desc_dma_vseq v = vseq;
        v.start(env.vseqr);
      join_none
    end
    wait fork;
    phase.drop_objection(this, "Infra stress test complete");
  endtask
endclass : axi_bridge_infra_test
