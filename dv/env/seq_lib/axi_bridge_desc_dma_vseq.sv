class axi_bridge_desc_dma_vseq extends axi_bridge_base_vseq;
  `uvm_object_utils(axi_bridge_desc_dma_vseq)

  rand int unsigned desc_idx;
  rand bit [31:0]   txn_type;   // 0 = write, 1 = read
  rand bit [31:0]   xfer_size;
  rand bit [63:0]   host_addr;

  constraint c_desc_idx { desc_idx inside {[0:`AXI_BRIDGE_MAX_DESC-1]}; }
  constraint c_txn_type { txn_type inside {0, 1}; }
  constraint c_size     { xfer_size inside {[1:4096]}; }

  function new(string name = "axi_bridge_desc_dma_vseq");
    super.new(name);
  endfunction

  task body();
    desc_t         d;
    uvm_status_e   status;
    axi_bridge_ral_pkg::desc_reg_block dreg;

    `uvm_info(get_type_name(),
      $sformatf("Programming desc[%0d] txn_type=%0d size=%0d addr=0x%0h",
                desc_idx, txn_type, xfer_size, host_addr), UVM_LOW)

    d.txn_type          = txn_type;
    d.size              = xfer_size;
    d.data_host_addr[0] = host_addr[31:0];
    d.data_host_addr[1] = host_addr[63:32];
    d.axaddr[0]         = host_addr[31:0];
    d.busy              = 1;
    d.ownership         = 0;

    // FIXED: this used to be a comment saying "TODO, wire scoreboard".
    // Now it actually programs the real descriptor registers via RAL,
    // which rides the S_AXI_USR sequencer through the adapter/predictor
    // wired in axi_bridge_env.connect_phase().
    dreg = cfg.ral.desc[desc_idx];
    dreg.txn_type.write(status, txn_type, .parent(this));
    dreg.size.write(status, xfer_size, .parent(this));
    dreg.data_host_addr[0].write(status, d.data_host_addr[0], .parent(this));
    dreg.data_host_addr[1].write(status, d.data_host_addr[1], .parent(this));
    dreg.axaddr[0].write(status, d.axaddr[0], .parent(this));

    // FIXED: predict on the scoreboard (handle obtained from cfg, wired
    // in axi_bridge_env.build_phase via cfg.set_scoreboard_handle()) so
    // DESC-COV actually samples and the scoreboard has a model to check
    // the eventual M_AXI transaction against.
    if (cfg.en_scb && cfg.get_scoreboard_handle() != null)
      cfg.get_scoreboard_handle().predict_desc_txn(desc_idx, d);

    // Trigger the descriptor via mode_select_reg's low bit as a stand-in
    // uc2hm_trig pulse - replace bit position/reg once the real trigger
    // mechanism's register mapping is confirmed against your RTL.
    cfg.ral.mode_select_reg.write(status, 32'h1, .parent(this));

    #100ns;
    `uvm_info(get_type_name(),
      $sformatf("Descriptor[%0d] trigger issued via mode_select_reg", desc_idx), UVM_LOW)
  endtask
endclass : axi_bridge_desc_dma_vseq
