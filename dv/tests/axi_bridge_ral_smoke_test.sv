class axi_bridge_ral_smoke_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_ral_smoke_test)

  function new(string name = "axi_bridge_ral_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_bridge_ral_smoke_vseq vseq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running RAL smoke vseq");
    vseq = axi_bridge_ral_smoke_vseq::type_id::create("vseq");
    vseq.cfg = cfg;
    vseq.start(env.vseqr);
    phase.drop_objection(this, "RAL smoke vseq complete");
  endtask
endclass : axi_bridge_ral_smoke_test
