interface axi_if #(
  parameter int ADDR_WIDTH = 64,
  parameter int DATA_WIDTH = 128,
  parameter int ID_WIDTH   = 4,
  parameter int USER_WIDTH = 32
) (
  input logic clk,
  input logic rst_n
);

  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [7:0]            awlen;
  logic [2:0]            awsize;
  logic [1:0]            awburst;
  logic                  awlock;
  logic [3:0]            awcache;
  logic [2:0]            awprot;
  logic [3:0]            awqos;
  logic [3:0]            awregion;
  logic [USER_WIDTH-1:0] awuser;
  logic                  awvalid;
  logic                  awready;

  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wlast;
  logic [USER_WIDTH-1:0]   wuser;
  logic                    wvalid;
  logic                    wready;

  logic [ID_WIDTH-1:0]   bid;
  logic [1:0]            bresp;
  logic [USER_WIDTH-1:0] buser;
  logic                  bvalid;
  logic                  bready;

  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [7:0]            arlen;
  logic [2:0]            arsize;
  logic [1:0]            arburst;
  logic                  arlock;
  logic [3:0]            arcache;
  logic [2:0]            arprot;
  logic [3:0]            arqos;
  logic [3:0]            arregion;
  logic [USER_WIDTH-1:0] aruser;
  logic                  arvalid;
  logic                  arready;

  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic [USER_WIDTH-1:0] ruser;
  logic                  rvalid;
  logic                  rready;

  clocking mon_cb @(posedge clk);
    input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot,
          awqos, awregion, awuser, awvalid, awready;
    input wdata, wstrb, wlast, wuser, wvalid, wready;
    input bid, bresp, buser, bvalid, bready;
    input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot,
          arqos, arregion, aruser, arvalid, arready;
    input rid, rdata, rresp, rlast, ruser, rvalid, rready;
  endclocking

  clocking drv_cb @(posedge clk);
    output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot,
           awqos, awregion, awuser, awvalid;
    input  awready;
    output wdata, wstrb, wlast, wuser, wvalid;
    input  wready;
    input  bid, bresp, buser, bvalid;
    output bready;
    output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot,
           arqos, arregion, aruser, arvalid;
    input  arready;
    input  rid, rdata, rresp, rlast, ruser, rvalid;
    output rready;
  endclocking

  // ADDED: srv_cb / slave modport - for a responder that answers someone
  // ELSE's AXI master (e.g. a memory model behind M_AXI). Directions are
  // the mirror image of drv_cb: aw/w/ar are inputs (sampling the real
  // master's request), b/r are outputs (this side answers).
  clocking srv_cb @(posedge clk);
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot,
           awqos, awregion, awuser, awvalid;
    output awready;
    input  wdata, wstrb, wlast, wuser, wvalid;
    output wready;
    output bid, bresp, buser, bvalid;
    input  bready;
    input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot,
           arqos, arregion, aruser, arvalid;
    output arready;
    output rid, rdata, rresp, rlast, ruser, rvalid;
    input  rready;
  endclocking

  modport master  (clocking drv_cb, input clk, rst_n);
  modport monitor (clocking mon_cb, input clk, rst_n);
  modport slave    (clocking srv_cb, input clk, rst_n);

  property p_awvalid_stable;
    @(posedge clk) disable iff (!rst_n)
    awvalid && !awready |=> awvalid;
  endproperty
  a_awvalid_stable: assert property(p_awvalid_stable)
    else $error("awvalid dropped before awready");

  property p_arvalid_stable;
    @(posedge clk) disable iff (!rst_n)
    arvalid && !arready |=> arvalid;
  endproperty
  a_arvalid_stable: assert property(p_arvalid_stable)
    else $error("arvalid dropped before arready");

  property p_no_x_on_awaddr;
    @(posedge clk) disable iff (!rst_n)
    awvalid |-> !$isunknown(awaddr);
  endproperty
  a_no_x_on_awaddr: assert property(p_no_x_on_awaddr)
    else $error("awaddr is X/Z while awvalid");

  property p_no_x_on_araddr;
    @(posedge clk) disable iff (!rst_n)
    arvalid |-> !$isunknown(araddr);
  endproperty
  a_no_x_on_araddr: assert property(p_no_x_on_araddr)
    else $error("araddr is X/Z while arvalid");

endinterface : axi_if
