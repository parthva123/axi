class axi_bridge_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_bridge_scoreboard)

  axi_bridge_env_cfg cfg;
  axi_bridge_env_cov  cov;

  // FIXED: removed the unused m_axi_export uvm_analysis_export - the
  // monitor's ap now connects DIRECTLY to m_axi_fifo.analysis_export in
  // axi_bridge_env.connect_phase(). Previously m_axi_export existed but
  // nothing fed it, and m_axi_fifo.get() blocked forever.
  uvm_tlm_analysis_fifo #(axi_seq_item) m_axi_fifo;

  desc_t desc_table[`AXI_BRIDGE_MAX_DESC];   // now actually populated by predict_desc_txn()

  int unsigned num_match;
  int unsigned num_mismatch;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_axi_fifo = new("m_axi_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_seq_item item;
    forever begin
      m_axi_fifo.get(item);
      if (cov != null) begin
        if (item.dir == axi_seq_item::WRITE_TXN) cov.write_write_txn(item);
        else                                     cov.write_read_txn(item);
      end
      check_txn(item);
    end
  endtask

  // FIXED: now actually called - see axi_bridge_desc_dma_vseq below, which
  // programs a descriptor via RAL and then calls this on the scoreboard
  // handle exposed through cfg (see vseq for the handle-passing pattern).
  function void predict_desc_txn(int unsigned idx, desc_t d);
    desc_table[idx] = d;
    if (cov != null)
      cov.write_desc_event(idx[3:0], d.txn_type, 1'b0);
    `uvm_info(get_type_name(),
      $sformatf("predict desc[%0d]: txn_type=%0d size=%0d addr=0x%0h",
                idx, d.txn_type, d.size, d.axaddr[0]), UVM_MEDIUM)
  endfunction

  function void check_txn(axi_seq_item item);
    if (item.dir == axi_seq_item::WRITE_TXN) begin
      if (item.wdata.size() != item.len + 1) begin
        num_mismatch++;
        `uvm_error(get_type_name(),
          $sformatf("Write beat count mismatch: expected %0d got %0d",
                    item.len + 1, item.wdata.size()))
      end else num_match++;
    end else begin
      if (item.rdata.size() != item.len + 1) begin
        num_mismatch++;
        `uvm_error(get_type_name(),
          $sformatf("Read beat count mismatch: expected %0d got %0d",
                    item.len + 1, item.rdata.size()))
      end else num_match++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("SCOREBOARD SUMMARY: match=%0d mismatch=%0d", num_match, num_mismatch), UVM_LOW)
    if (num_mismatch != 0)
      `uvm_error(get_type_name(), "Scoreboard reported non-zero mismatches")
  endfunction
endclass : axi_bridge_scoreboard
