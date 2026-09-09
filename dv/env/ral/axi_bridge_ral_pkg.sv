package axi_bridge_ral_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "../reg_defs/axi_bridge_reg_defs.sv"

  parameter int NUM_DESC = `AXI_BRIDGE_MAX_DESC;

  class reg32_rw extends uvm_reg;
    rand uvm_reg_field value;
    `uvm_object_utils(reg32_rw)
    function new(string name = "reg32_rw"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      value = uvm_reg_field::type_id::create("value");
      value.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass : reg32_rw

  class reg32_ro extends uvm_reg;
    rand uvm_reg_field value;
    `uvm_object_utils(reg32_ro)
    function new(string name = "reg32_ro"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      value = uvm_reg_field::type_id::create("value");
      value.configure(this, 32, 0, "RO", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass : reg32_ro

  class reg32_w1c extends uvm_reg;
    rand uvm_reg_field value;
    `uvm_object_utils(reg32_w1c)
    function new(string name = "reg32_w1c"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      value = uvm_reg_field::type_id::create("value");
      value.configure(this, 32, 0, "W1C", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass : reg32_w1c

  class desc_reg_block extends uvm_reg_block;
    `uvm_object_utils(desc_reg_block)

    rand reg32_rw txn_type;
    rand reg32_rw size;
    rand reg32_rw data_offset;
    rand reg32_rw data_host_addr[4];
    rand reg32_rw wstrb_host_addr[4];
    rand reg32_rw axsize;
    rand reg32_rw attr;
    rand reg32_rw axaddr[4];
    rand reg32_rw axid[4];
    rand reg32_rw axuser[16];   // ADDED: found in slave_all.vh, missing from original model
    rand reg32_rw xuser[16];    // ADDED: same

    uvm_reg_map map;

    function new(string name = "desc_reg_block");
      super.new(name, UVM_NO_COVERAGE);
    endfunction

    // FIXED: build(base_offset) now only creates+configures registers and
    // adds them to the map; it is called AFTER configure() from the
    // parent block, matching standard UVM RAL construction order
    // (configure -> build -> lock_model), instead of the previous
    // build-before-configure ordering.
    virtual function void build(uvm_reg_addr_t base_offset);
      map = create_map("map", 0, 4, UVM_LITTLE_ENDIAN);

      txn_type = reg32_rw::type_id::create("txn_type");
      txn_type.configure(this); txn_type.build();
      map.add_reg(txn_type, base_offset + `DESC_TXN_TYPE_OFFSET, "RW");

      size = reg32_rw::type_id::create("size");
      size.configure(this); size.build();
      map.add_reg(size, base_offset + `DESC_SIZE_OFFSET, "RW");

      data_offset = reg32_rw::type_id::create("data_offset");
      data_offset.configure(this); data_offset.build();
      map.add_reg(data_offset, base_offset + `DESC_DATA_OFFSET_OFFSET, "RW");

      foreach (data_host_addr[i]) begin
        data_host_addr[i] = reg32_rw::type_id::create($sformatf("data_host_addr%0d", i));
        data_host_addr[i].configure(this); data_host_addr[i].build();
        map.add_reg(data_host_addr[i], base_offset + `DESC_DATA_HOST_ADDR0_OFFSET + i*4, "RW");
      end

      foreach (wstrb_host_addr[i]) begin
        wstrb_host_addr[i] = reg32_rw::type_id::create($sformatf("wstrb_host_addr%0d", i));
        wstrb_host_addr[i].configure(this); wstrb_host_addr[i].build();
        map.add_reg(wstrb_host_addr[i], base_offset + `DESC_WSTRB_HOST_ADDR0_OFFSET + i*4, "RW");
      end

      axsize = reg32_rw::type_id::create("axsize");
      axsize.configure(this); axsize.build();
      map.add_reg(axsize, base_offset + `DESC_AXSIZE_OFFSET, "RW");

      attr = reg32_rw::type_id::create("attr");
      attr.configure(this); attr.build();
      map.add_reg(attr, base_offset + `DESC_ATTR_OFFSET, "RW");

      foreach (axaddr[i]) begin
        axaddr[i] = reg32_rw::type_id::create($sformatf("axaddr%0d", i));
        axaddr[i].configure(this); axaddr[i].build();
        map.add_reg(axaddr[i], base_offset + `DESC_AXADDR0_OFFSET + i*4, "RW");
      end

      foreach (axid[i]) begin
        axid[i] = reg32_rw::type_id::create($sformatf("axid%0d", i));
        axid[i].configure(this); axid[i].build();
        map.add_reg(axid[i], base_offset + `DESC_AXID0_OFFSET + i*4, "RW");
      end

      // ADDED: axuser[16] and xuser[16] - discovered in slave_all.vh,
      // missing from the original hand-derived descriptor register model.
      foreach (axuser[i]) begin
        axuser[i] = reg32_rw::type_id::create($sformatf("axuser%0d", i));
        axuser[i].configure(this); axuser[i].build();
        map.add_reg(axuser[i], base_offset + `DESC_AXUSER0_OFFSET + i*4, "RW");
      end

      foreach (xuser[i]) begin
        xuser[i] = reg32_rw::type_id::create($sformatf("xuser%0d", i));
        xuser[i].configure(this); xuser[i].build();
        map.add_reg(xuser[i], base_offset + `DESC_XUSER0_OFFSET + i*4, "RW");
      end

      lock_model();
    endfunction
  endclass : desc_reg_block

  class axi_bridge_reg_block extends uvm_reg_block;
    `uvm_object_utils(axi_bridge_reg_block)

    rand reg32_ro bridge_identification_reg;
    rand reg32_ro bridge_position_reg;
    rand reg32_ro version_reg;
    rand reg32_ro bridge_type_reg;
    rand reg32_rw mode_select_reg;
    rand reg32_rw reset_reg;
    rand reg32_rw h2c_intr_0_reg, h2c_intr_1_reg, h2c_intr_2_reg, h2c_intr_3_reg;
    rand reg32_ro c2h_intr_status_0_reg, c2h_intr_status_1_reg;
    rand reg32_ro intr_c2h_toggle_status_0_reg, intr_c2h_toggle_status_1_reg;
    rand reg32_w1c intr_c2h_toggle_clear_0_reg, intr_c2h_toggle_clear_1_reg;
    rand reg32_rw intr_c2h_toggle_enable_0_reg, intr_c2h_toggle_enable_1_reg;
    rand reg32_ro c2h_gpio_reg[16];
    rand reg32_rw h2c_gpio_reg[16];
    rand reg32_rw h2c_pulse_0_reg, h2c_pulse_1_reg;
    rand reg32_rw axi_bridge_config_reg;
    rand reg32_ro axi_max_desc_reg;
    rand reg32_ro intr_status_reg;
    rand reg32_ro intr_error_status_reg;
    rand reg32_w1c intr_error_clear_reg;
    rand reg32_rw intr_error_enable_reg;
    rand reg32_rw bridge_rd_user_config_reg, bridge_wr_user_config_reg;
    // ADDED: address-translation registers (found in slave_all.vh)
    rand reg32_rw addr_in_reg[4];
    rand reg32_rw trans_mask_reg[4];
    rand reg32_rw trans_addr_reg[4];

    rand reg32_rw ownership_reg, ownership_flip_reg;
    rand reg32_ro status_resp_reg;
    // ADDED: txn-avail / comp / busy / resp-order status registers
    rand reg32_ro intr_txn_avail_status_reg;
    rand reg32_w1c intr_txn_avail_clear_reg;
    rand reg32_rw intr_txn_avail_enable_reg;
    rand reg32_ro status_resp_comp_reg;
    rand reg32_ro status_busy_reg;
    rand reg32_ro intr_comp_status_reg;
    rand reg32_w1c intr_comp_clear_reg;
    rand reg32_rw intr_comp_enable_reg;
    rand reg32_rw resp_order_reg;
    rand reg32_ro resp_fifo_free_level_reg;

    desc_reg_block desc[NUM_DESC];
    uvm_reg_map map;

    function new(string name = "axi_bridge_reg_block");
      super.new(name, UVM_NO_COVERAGE);
    endfunction

    `define BUILD_RO(NAME, ADDR) \
      NAME = reg32_ro::type_id::create(`"NAME`"); \
      NAME.configure(this); NAME.build(); \
      map.add_reg(NAME, ADDR, "RO");

    `define BUILD_RW(NAME, ADDR) \
      NAME = reg32_rw::type_id::create(`"NAME`"); \
      NAME.configure(this); NAME.build(); \
      map.add_reg(NAME, ADDR, "RW");

    `define BUILD_W1C(NAME, ADDR) \
      NAME = reg32_w1c::type_id::create(`"NAME`"); \
      NAME.configure(this); NAME.build(); \
      map.add_reg(NAME, ADDR, "RW");

    virtual function void build();
      map = create_map("axi_bridge_map", 0, 4, UVM_LITTLE_ENDIAN);

      `BUILD_RO(bridge_identification_reg, `BRIDGE_IDENTIFICATION_REG_ADDR)
      `BUILD_RO(bridge_position_reg,       `BRIDGE_POSITION_REG_ADDR)
      `BUILD_RO(version_reg,               `VERSION_REG_ADDR)
      `BUILD_RO(bridge_type_reg,           `BRIDGE_TYPE_REG_ADDR)
      `BUILD_RW(mode_select_reg,           `MODE_SELECT_REG_ADDR)
      `BUILD_RW(reset_reg,                 `RESET_REG_ADDR)
      `BUILD_RW(h2c_intr_0_reg, `H2C_INTR_0_REG_ADDR)
      `BUILD_RW(h2c_intr_1_reg, `H2C_INTR_1_REG_ADDR)
      `BUILD_RW(h2c_intr_2_reg, `H2C_INTR_2_REG_ADDR)
      `BUILD_RW(h2c_intr_3_reg, `H2C_INTR_3_REG_ADDR)
      `BUILD_RO(c2h_intr_status_0_reg,        `C2H_INTR_STATUS_0_REG_ADDR)
      `BUILD_RO(c2h_intr_status_1_reg,        `C2H_INTR_STATUS_1_REG_ADDR)
      `BUILD_RO(intr_c2h_toggle_status_0_reg, `INTR_C2H_TOGGLE_STATUS_0_REG_ADDR)
      `BUILD_RO(intr_c2h_toggle_status_1_reg, `INTR_C2H_TOGGLE_STATUS_1_REG_ADDR)
      `BUILD_W1C(intr_c2h_toggle_clear_0_reg, `INTR_C2H_TOGGLE_CLEAR_0_REG_ADDR)
      `BUILD_W1C(intr_c2h_toggle_clear_1_reg, `INTR_C2H_TOGGLE_CLEAR_1_REG_ADDR)
      `BUILD_RW(intr_c2h_toggle_enable_0_reg, `INTR_C2H_TOGGLE_ENABLE_0_REG_ADDR)
      `BUILD_RW(intr_c2h_toggle_enable_1_reg, `INTR_C2H_TOGGLE_ENABLE_1_REG_ADDR)

      foreach (c2h_gpio_reg[i]) begin
        c2h_gpio_reg[i] = reg32_ro::type_id::create($sformatf("c2h_gpio_%0d_reg", i));
        c2h_gpio_reg[i].configure(this); c2h_gpio_reg[i].build();
        map.add_reg(c2h_gpio_reg[i], `C2H_GPIO_BASE_ADDR + i*4, "RO");
      end
      foreach (h2c_gpio_reg[i]) begin
        h2c_gpio_reg[i] = reg32_rw::type_id::create($sformatf("h2c_gpio_%0d_reg", i));
        h2c_gpio_reg[i].configure(this); h2c_gpio_reg[i].build();
        map.add_reg(h2c_gpio_reg[i], `H2C_GPIO_BASE_ADDR + i*4, "RW");
      end

      `BUILD_RW(h2c_pulse_0_reg, `H2C_PULSE_0_REG_ADDR)
      `BUILD_RW(h2c_pulse_1_reg, `H2C_PULSE_1_REG_ADDR)
      `BUILD_RW(axi_bridge_config_reg,      `AXI_BRIDGE_CONFIG_REG_ADDR)
      `BUILD_RO(axi_max_desc_reg,           `AXI_MAX_DESC_REG_ADDR)
      `BUILD_RO(intr_status_reg,            `INTR_STATUS_REG_ADDR)
      `BUILD_RO(intr_error_status_reg,      `INTR_ERROR_STATUS_REG_ADDR)
      `BUILD_W1C(intr_error_clear_reg,      `INTR_ERROR_CLEAR_REG_ADDR)
      `BUILD_RW(intr_error_enable_reg,      `INTR_ERROR_ENABLE_REG_ADDR)
      `BUILD_RW(bridge_rd_user_config_reg,  `BRIDGE_RD_USER_CONFIG_REG_ADDR)
      `BUILD_RW(bridge_wr_user_config_reg,  `BRIDGE_WR_USER_CONFIG_REG_ADDR)
      // ADDED: address-translation register arrays
      foreach (addr_in_reg[i]) begin
        addr_in_reg[i] = reg32_rw::type_id::create($sformatf("addr_in_%0d_reg", i));
        addr_in_reg[i].configure(this); addr_in_reg[i].build();
        map.add_reg(addr_in_reg[i], `ADDR_IN_0_REG_ADDR + i*4, "RW");
      end
      foreach (trans_mask_reg[i]) begin
        trans_mask_reg[i] = reg32_rw::type_id::create($sformatf("trans_mask_%0d_reg", i));
        trans_mask_reg[i].configure(this); trans_mask_reg[i].build();
        map.add_reg(trans_mask_reg[i], `TRANS_MASK_0_REG_ADDR + i*4, "RW");
      end
      foreach (trans_addr_reg[i]) begin
        trans_addr_reg[i] = reg32_rw::type_id::create($sformatf("trans_addr_%0d_reg", i));
        trans_addr_reg[i].configure(this); trans_addr_reg[i].build();
        map.add_reg(trans_addr_reg[i], `TRANS_ADDR_0_REG_ADDR + i*4, "RW");
      end

      `BUILD_RW(ownership_reg,          `OWNERSHIP_REG_ADDR)
      `BUILD_RW(ownership_flip_reg,     `OWNERSHIP_FLIP_REG_ADDR)
      `BUILD_RO(status_resp_reg,        `STATUS_RESP_REG_ADDR)
      // ADDED: txn-avail / comp / busy / resp-order status registers
      `BUILD_RO(intr_txn_avail_status_reg, `INTR_TXN_AVAIL_STATUS_REG_ADDR)
      `BUILD_W1C(intr_txn_avail_clear_reg, `INTR_TXN_AVAIL_CLEAR_REG_ADDR)
      `BUILD_RW(intr_txn_avail_enable_reg, `INTR_TXN_AVAIL_ENABLE_REG_ADDR)
      `BUILD_RO(status_resp_comp_reg,      `STATUS_RESP_COMP_REG_ADDR)
      `BUILD_RO(status_busy_reg,           `STATUS_BUSY_REG_ADDR)
      `BUILD_RO(intr_comp_status_reg,   `INTR_COMP_STATUS_REG_ADDR)
      `BUILD_W1C(intr_comp_clear_reg,   `INTR_COMP_CLEAR_REG_ADDR)
      `BUILD_RW(intr_comp_enable_reg,   `INTR_COMP_ENABLE_REG_ADDR)
      `BUILD_RW(resp_order_reg,            `RESP_ORDER_REG_ADDR)
      `BUILD_RO(resp_fifo_free_level_reg,  `RESP_FIFO_FREE_LEVEL_REG_ADDR)

      // FIXED: configure() now called before build() for each desc block.
      foreach (desc[i]) begin
        desc[i] = desc_reg_block::type_id::create($sformatf("desc_%0d", i));
        desc[i].configure(this, "");
        desc[i].build(`DESC_BASE_ADDR + i*`DESC_STRIDE);
        add_submap(desc[i].map, `DESC_BASE_ADDR + i*`DESC_STRIDE);
      end

      lock_model();
    endfunction

    `undef BUILD_RO
    `undef BUILD_RW
    `undef BUILD_W1C
  endclass : axi_bridge_reg_block

endpackage : axi_bridge_ral_pkg
