//------------------------------------------------------------------------
// m_axi_mem_model.sv
// A minimal AXI4 slave/memory model that answers whatever the DUT issues
// on M_AXI. Without this nothing the DUT masters ever completes -
// awready/wready/bvalid/arready/rvalid/rdata all just sit at 0 forever.
// Not randomized/backpressure-capable by design (keep it simple and
// always-ready first); extend with configurable ready-delay and
// SLVERR/DECERR injection once basic passthrough tests are green.
//------------------------------------------------------------------------
module m_axi_mem_model #(
  parameter int ADDR_WIDTH     = 64,
  parameter int DATA_WIDTH     = 128,
  parameter int ID_WIDTH       = 16,
  parameter int MEM_SIZE_BYTES = 16384
) (
  axi_if.slave axi_if
);

  localparam int STRB_WIDTH  = DATA_WIDTH/8;
  localparam int MEM_WORDS   = MEM_SIZE_BYTES / STRB_WIDTH;
  localparam int WORD_ADDR_B = $clog2(STRB_WIDTH);

  logic [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];

  // ---------------- Write channel ----------------
  typedef enum { W_IDLE, W_BURST, W_RESP } wr_state_e;
  wr_state_e wr_state;
  logic [ID_WIDTH-1:0]   aw_id_q;
  logic [ADDR_WIDTH-1:0] aw_addr_q;
  logic [7:0]            aw_len_q;
  logic [7:0]            beat_cnt_q;

  always @(posedge axi_if.clk) begin
    if (!axi_if.rst_n) begin
      axi_if.srv_cb.awready <= 1'b0;
      axi_if.srv_cb.wready  <= 1'b0;
      axi_if.srv_cb.bvalid  <= 1'b0;
      wr_state <= W_IDLE;
      beat_cnt_q <= 0;
    end else begin
      case (wr_state)
        W_IDLE: begin
          axi_if.srv_cb.awready <= 1'b1;
          axi_if.srv_cb.wready  <= 1'b0;
          if (axi_if.srv_cb.awvalid && axi_if.srv_cb.awready) begin
            aw_id_q    <= axi_if.srv_cb.awid;
            aw_addr_q  <= axi_if.srv_cb.awaddr;
            aw_len_q   <= axi_if.srv_cb.awlen;
            beat_cnt_q <= 0;
            axi_if.srv_cb.awready <= 1'b0;
            axi_if.srv_cb.wready  <= 1'b1;
            wr_state   <= W_BURST;
          end
        end
        W_BURST: begin
          if (axi_if.srv_cb.wvalid && axi_if.srv_cb.wready) begin
            automatic int word_idx = (aw_addr_q >> WORD_ADDR_B) + beat_cnt_q;
            if (word_idx < MEM_WORDS) begin
              for (int b = 0; b < STRB_WIDTH; b++)
                if (axi_if.srv_cb.wstrb[b]) mem[word_idx][b*8 +: 8] <= axi_if.srv_cb.wdata[b*8 +: 8];
            end
            if (axi_if.srv_cb.wlast) begin
              axi_if.srv_cb.wready <= 1'b0;
              axi_if.srv_cb.bvalid <= 1'b1;
              axi_if.srv_cb.bid    <= aw_id_q;
              axi_if.srv_cb.bresp  <= 2'b00;
              wr_state <= W_RESP;
            end else begin
              beat_cnt_q <= beat_cnt_q + 1;
            end
          end
        end
        W_RESP: begin
          if (axi_if.srv_cb.bvalid && axi_if.srv_cb.bready) begin
            axi_if.srv_cb.bvalid  <= 1'b0;
            axi_if.srv_cb.awready <= 1'b1;
            wr_state <= W_IDLE;
          end
        end
      endcase
    end
  end

  // ---------------- Read channel ----------------
  typedef enum { R_IDLE, R_BURST } rd_state_e;
  rd_state_e rd_state;
  logic [ID_WIDTH-1:0]   ar_id_q;
  logic [ADDR_WIDTH-1:0] ar_addr_q;
  logic [7:0]            ar_len_q;
  logic [7:0]            rbeat_cnt_q;

  always @(posedge axi_if.clk) begin
    if (!axi_if.rst_n) begin
      axi_if.srv_cb.arready <= 1'b0;
      axi_if.srv_cb.rvalid  <= 1'b0;
      rd_state <= R_IDLE;
      rbeat_cnt_q <= 0;
    end else begin
      case (rd_state)
        R_IDLE: begin
          axi_if.srv_cb.arready <= 1'b1;
          if (axi_if.srv_cb.arvalid && axi_if.srv_cb.arready) begin
            ar_id_q     <= axi_if.srv_cb.arid;
            ar_addr_q   <= axi_if.srv_cb.araddr;
            ar_len_q    <= axi_if.srv_cb.arlen;
            rbeat_cnt_q <= 0;
            axi_if.srv_cb.arready <= 1'b0;
            axi_if.srv_cb.rvalid  <= 1'b1;
            rd_state <= R_BURST;
          end
        end
        R_BURST: begin
          automatic int word_idx = (ar_addr_q >> WORD_ADDR_B) + rbeat_cnt_q;
          axi_if.srv_cb.rid   <= ar_id_q;
          axi_if.srv_cb.rdata <= (word_idx < MEM_WORDS) ? mem[word_idx] : '0;
          axi_if.srv_cb.rresp <= 2'b00;
          axi_if.srv_cb.rlast <= (rbeat_cnt_q == ar_len_q);
          if (axi_if.srv_cb.rvalid && axi_if.srv_cb.rready) begin
            if (rbeat_cnt_q == ar_len_q) begin
              axi_if.srv_cb.rvalid  <= 1'b0;
              axi_if.srv_cb.arready <= 1'b1;
              rd_state <= R_IDLE;
            end else begin
              rbeat_cnt_q <= rbeat_cnt_q + 1;
            end
          end
        end
      endcase
    end
  end

  initial begin
    for (int i = 0; i < MEM_WORDS; i++) mem[i] = '0;
  end

endmodule : m_axi_mem_model
