class axi_bridge_sys_test extends axi_bridge_base_test;
  `uvm_component_utils(axi_bridge_sys_test)
  int unsigned soak_iters = 30;

  function new(string name = "axi_bridge_sys_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this, "Running system soak test");
    fork
      begin : soak_writes
        axi_rand_write_seq wseq;
        repeat (soak_iters) begin
          wseq = axi_rand_write_seq::type_id::create("wseq");
          wseq.num_txns = 3;
          wseq.start(env.vseqr.s_axi_usr_sqr);   // FIXED: real burst traffic goes on S_AXI_USR, not AXI4-Lite S_AXI
        end
      end
      begin : soak_desc
        axi_bridge_desc_dma_vseq dseq;
        repeat (soak_iters) begin
          dseq = axi_bridge_desc_dma_vseq::type_id::create("dseq");
          dseq.cfg = cfg;
          void'(dseq.randomize());
          dseq.start(env.vseqr);
        end
      end
      begin : soak_intr
        reg_intr_gpio_toggle_seq gseq;
        repeat (soak_iters / 3) begin
          gseq = reg_intr_gpio_toggle_seq::type_id::create("gseq");
          void'(gseq.randomize());
          gseq.start(env.vseqr.reg_intr_sqr);
          #200ns;
        end
      end
      begin : mid_test_reset
        if (cfg.en_async_reset_injection) begin
          #500ns;
          cfg.clk_rst_vif.inject_async_reset(3);
        end
      end
    join
    phase.drop_objection(this, "System soak test complete");
  endtask
endclass : axi_bridge_sys_test
