class axi_seq_item extends uvm_sequence_item;

  typedef enum bit [1:0] { AXI_FIXED = 2'b00, AXI_INCR = 2'b01, AXI_WRAP = 2'b10 } burst_e;
  typedef enum bit       { WRITE_TXN = 1'b0, READ_TXN = 1'b1 } dir_e;
  typedef enum bit [1:0] { RESP_OKAY = 2'b00, RESP_EXOKAY = 2'b01,
                            RESP_SLVERR = 2'b10, RESP_DECERR = 2'b11 } resp_e;

  rand dir_e      dir;
  rand bit [63:0] addr;
  rand bit [7:0]  len;
  rand bit [2:0]  size;
  rand burst_e    burst;
  rand bit [3:0]  id;
  rand bit [31:0] user;

  rand bit [127:0] wdata[$];
  rand bit [15:0]  wstrb[$];
  bit  [127:0]     rdata[$];
  resp_e           resp;

  constraint c_size_legal { size inside {[0:4]}; }
  constraint c_len_axi4   { len inside {[0:255]}; }
  constraint c_wrap_pow2  { (burst == AXI_WRAP) -> (len inside {1,3,7,15}); }
  constraint c_addr_align { addr[2:0] == 3'b0; }

  `uvm_object_utils_begin(axi_seq_item)
    `uvm_field_enum(dir_e, dir, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(len, UVM_ALL_ON)
    `uvm_field_int(size, UVM_ALL_ON)
    `uvm_field_enum(burst_e, burst, UVM_ALL_ON)
    `uvm_field_int(id, UVM_ALL_ON)
    `uvm_field_int(user, UVM_ALL_ON)
    `uvm_field_queue_int(wdata, UVM_ALL_ON)
    `uvm_field_queue_int(wstrb, UVM_ALL_ON)
    `uvm_field_queue_int(rdata, UVM_ALL_ON)
    `uvm_field_enum(resp_e, resp, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("dir=%s addr=0x%0h len=%0d size=%0d burst=%s id=%0d",
                      dir.name(), addr, len, size, burst.name(), id);
  endfunction

endclass : axi_seq_item
