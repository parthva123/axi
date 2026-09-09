class reg_intr_gpio_toggle_seq extends reg_intr_base_seq;
  `uvm_object_utils(reg_intr_gpio_toggle_seq)

  rand bit [255:0] gpio_pattern;

  function new(string name = "reg_intr_gpio_toggle_seq");
    super.new(name);
  endfunction

  task body();
    reg_intr_seq_item item;

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op = reg_intr_seq_item::GPIO_DRIVE;
    item.c2h_gpio_drive = gpio_pattern;
    finish_item(item);

    #50ns;

    item = reg_intr_seq_item::type_id::create("item");
    start_item(item);
    item.op = reg_intr_seq_item::GPIO_DRIVE;
    item.c2h_gpio_drive = ~gpio_pattern;
    finish_item(item);
  endtask
endclass : reg_intr_gpio_toggle_seq
