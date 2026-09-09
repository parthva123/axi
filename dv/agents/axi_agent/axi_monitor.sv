class axi_monitor #(
  int ADDR_WIDTH = 64,
  int DATA_WIDTH = 128,
  int ID_WIDTH   = 4,
  int USER_WIDTH = 32
) extends uvm_monitor;

  `uvm_component_param_utils(axi_monitor#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH))

  typedef axi_agent_cfg#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH) cfg_t;
  cfg_t cfg;
  virtual axi_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                    .ID_WIDTH(ID_WIDTH), .USER_WIDTH(USER_WIDTH)) vif;

  uvm_analysis_port #(axi_seq_item) ap;

  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(cfg_t)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get axi_agent_cfg")
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    fork
      mon_write();
      mon_read();
    join
  endtask

  task mon_write();
    axi_seq_item item;
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.awvalid && vif.mon_cb.awready) begin
        item = axi_seq_item::type_id::create("mon_wr_item");
        item.dir   = axi_seq_item::WRITE_TXN;
        item.id    = vif.mon_cb.awid;
        item.addr  = vif.mon_cb.awaddr;
        item.len   = vif.mon_cb.awlen;
        item.size  = vif.mon_cb.awsize;
        item.burst = axi_seq_item::burst_e'(vif.mon_cb.awburst);
        item.wdata.delete();
        item.wstrb.delete();
        forever begin
          @(vif.mon_cb);
          if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
            item.wdata.push_back(vif.mon_cb.wdata);
            item.wstrb.push_back(vif.mon_cb.wstrb);
            if (vif.mon_cb.wlast) break;
          end
        end
        wait (vif.mon_cb.bvalid && vif.mon_cb.bready);
        item.resp = axi_seq_item::resp_e'(vif.mon_cb.bresp);
        ap.write(item);
      end
    end
  endtask

  task mon_read();
    axi_seq_item item;
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.arvalid && vif.mon_cb.arready) begin
        item = axi_seq_item::type_id::create("mon_rd_item");
        item.dir   = axi_seq_item::READ_TXN;
        item.id    = vif.mon_cb.arid;
        item.addr  = vif.mon_cb.araddr;
        item.len   = vif.mon_cb.arlen;
        item.size  = vif.mon_cb.arsize;
        item.burst = axi_seq_item::burst_e'(vif.mon_cb.arburst);
        item.rdata.delete();
        forever begin
          @(vif.mon_cb);
          if (vif.mon_cb.rvalid && vif.mon_cb.rready) begin
            item.rdata.push_back(vif.mon_cb.rdata);
            item.resp = axi_seq_item::resp_e'(vif.mon_cb.rresp);
            if (vif.mon_cb.rlast) break;
          end
        end
        ap.write(item);
      end
    end
  endtask

endclass : axi_monitor
