class axi_driver #(
  int ADDR_WIDTH = 64,
  int DATA_WIDTH = 128,
  int ID_WIDTH   = 4,
  int USER_WIDTH = 32
) extends uvm_driver #(axi_seq_item);

  `uvm_component_param_utils(axi_driver#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH))

  typedef axi_agent_cfg#(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH, USER_WIDTH) cfg_t;
  cfg_t cfg;
  virtual axi_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                    .ID_WIDTH(ID_WIDTH), .USER_WIDTH(USER_WIDTH)) vif;

  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(cfg_t)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get axi_agent_cfg")
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    reset_signals();
    forever begin
      seq_item_port.get_next_item(req);
      if (req.dir == axi_seq_item::WRITE_TXN) drive_write(req);
      else                                     drive_read(req);
      seq_item_port.item_done();
    end
  endtask

  task reset_signals();
    vif.drv_cb.awvalid <= 0;
    vif.drv_cb.wvalid  <= 0;
    vif.drv_cb.bready  <= 0;
    vif.drv_cb.arvalid <= 0;
    vif.drv_cb.rready  <= 0;
    @(posedge vif.rst_n);
  endtask

  task drive_write(axi_seq_item item);
    vif.drv_cb.awid    <= item.id;
    vif.drv_cb.awaddr  <= item.addr;
    vif.drv_cb.awlen   <= item.len;
    vif.drv_cb.awsize  <= item.size;
    vif.drv_cb.awburst <= item.burst;
    vif.drv_cb.awuser  <= item.user;
    vif.drv_cb.awvalid <= 1;
    do @(vif.drv_cb); while (!vif.drv_cb.awready);
    vif.drv_cb.awvalid <= 0;

    for (int i = 0; i <= item.len; i++) begin
      vif.drv_cb.wdata  <= item.wdata[i];
      vif.drv_cb.wstrb  <= item.wstrb[i];
      vif.drv_cb.wlast  <= (i == item.len);
      vif.drv_cb.wvalid <= 1;
      do @(vif.drv_cb); while (!vif.drv_cb.wready);
    end
    vif.drv_cb.wvalid <= 0;
    vif.drv_cb.wlast  <= 0;

    vif.drv_cb.bready <= 1;
    do @(vif.drv_cb); while (!vif.drv_cb.bvalid);
    item.resp = axi_seq_item::resp_e'(vif.drv_cb.bresp);
    vif.drv_cb.bready <= 0;
  endtask

  task drive_read(axi_seq_item item);
    vif.drv_cb.arid    <= item.id;
    vif.drv_cb.araddr  <= item.addr;
    vif.drv_cb.arlen   <= item.len;
    vif.drv_cb.arsize  <= item.size;
    vif.drv_cb.arburst <= item.burst;
    vif.drv_cb.aruser  <= item.user;
    vif.drv_cb.arvalid <= 1;
    do @(vif.drv_cb); while (!vif.drv_cb.arready);
    vif.drv_cb.arvalid <= 0;

    vif.drv_cb.rready <= 1;
    item.rdata.delete();
    forever begin
      @(vif.drv_cb);
      if (vif.drv_cb.rvalid) begin
        item.rdata.push_back(vif.drv_cb.rdata);
        item.resp = axi_seq_item::resp_e'(vif.drv_cb.rresp);
        if (vif.drv_cb.rlast) break;
      end
    end
    vif.drv_cb.rready <= 0;
  endtask

endclass : axi_driver
