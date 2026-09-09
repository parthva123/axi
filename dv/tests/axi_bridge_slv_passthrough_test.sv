class axi_bridge_slv_passthrough_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_slv_passthrough_test)

  function new(string name = "axi_bridge_slv_passthrough_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_bridge_slv_passthrough_vseq vseq;
    super.run_phase(phase);
    phase.raise_objection(this, "Running S_AXI_USR -> M_AXI passthrough vseq");
    vseq = axi_bridge_slv_passthrough_vseq::type_id::create("vseq");
    vseq.cfg = cfg;
    vseq.start(env.vseqr);
    phase.drop_objection(this, "Passthrough vseq complete");
  endtask
endclass : axi_bridge_slv_passthrough_test
