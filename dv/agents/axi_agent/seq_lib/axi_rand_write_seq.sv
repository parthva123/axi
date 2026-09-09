class axi_rand_write_seq extends axi_base_seq;
  `uvm_object_utils(axi_rand_write_seq)

  rand int unsigned num_txns = 10;

  function new(string name = "axi_rand_write_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;
    repeat (num_txns) begin
      item = axi_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            dir == axi_seq_item::WRITE_TXN;
            wdata.size() == len + 1;
            wstrb.size() == len + 1;
          })
        `uvm_fatal(get_type_name(), "Randomization failed")
      finish_item(item);
    end
  endtask
endclass : axi_rand_write_seq
