`ifndef AXI_BRIDGE_REG_DEFS_SV
`define AXI_BRIDGE_REG_DEFS_SV
// Verified against slave_all.vh - exact offsets, not reconstructed.

`define BRIDGE_IDENTIFICATION_REG_ADDR   'h000
`define BRIDGE_POSITION_REG_ADDR         'h004
`define VERSION_REG_ADDR                 'h020
`define BRIDGE_TYPE_REG_ADDR             'h024
`define MODE_SELECT_REG_ADDR             'h038
`define RESET_REG_ADDR                   'h03C

`define H2C_INTR_0_REG_ADDR              'h040
`define H2C_INTR_1_REG_ADDR              'h044
`define H2C_INTR_2_REG_ADDR              'h048
`define H2C_INTR_3_REG_ADDR              'h04C

`define C2H_INTR_STATUS_0_REG_ADDR             'h060
`define INTR_C2H_TOGGLE_STATUS_0_REG_ADDR      'h064
`define INTR_C2H_TOGGLE_CLEAR_0_REG_ADDR       'h068
`define INTR_C2H_TOGGLE_ENABLE_0_REG_ADDR      'h06C
`define C2H_INTR_STATUS_1_REG_ADDR             'h070
`define INTR_C2H_TOGGLE_STATUS_1_REG_ADDR      'h074
`define INTR_C2H_TOGGLE_CLEAR_1_REG_ADDR       'h078
`define INTR_C2H_TOGGLE_ENABLE_1_REG_ADDR      'h07C

// C2H_GPIO_0..15_REG_ADDR = 'h080 + i*4 ('h080..'hBC)
// H2C_GPIO_0..15_REG_ADDR = 'h0C0 + i*4 ('h0C0..'hFC)
`define C2H_GPIO_BASE_ADDR               'h080
`define H2C_GPIO_BASE_ADDR               'h0C0
`define H2C_PULSE_0_REG_ADDR             'h100
`define H2C_PULSE_1_REG_ADDR             'h104

`define AXI_BRIDGE_CONFIG_REG_ADDR       'h200
`define AXI_MAX_DESC_REG_ADDR            'h204
`define INTR_STATUS_REG_ADDR             'h208
`define INTR_ERROR_STATUS_REG_ADDR       'h20C
`define INTR_ERROR_CLEAR_REG_ADDR        'h210
`define INTR_ERROR_ENABLE_REG_ADDR       'h214
`define BRIDGE_RD_USER_CONFIG_REG_ADDR   'h218
`define BRIDGE_WR_USER_CONFIG_REG_ADDR   'h21C

// Address-translation registers (found in slave_all.vh - missing from
// the original hand-derived reconstruction)
`define ADDR_IN_0_REG_ADDR               'h220
`define ADDR_IN_1_REG_ADDR               'h224
`define ADDR_IN_2_REG_ADDR               'h228
`define ADDR_IN_3_REG_ADDR               'h22C
`define TRANS_MASK_0_REG_ADDR            'h230
`define TRANS_MASK_1_REG_ADDR            'h234
`define TRANS_MASK_2_REG_ADDR            'h238
`define TRANS_MASK_3_REG_ADDR            'h23C
`define TRANS_ADDR_0_REG_ADDR            'h240
`define TRANS_ADDR_1_REG_ADDR            'h244
`define TRANS_ADDR_2_REG_ADDR            'h248
`define TRANS_ADDR_3_REG_ADDR            'h24C

`define OWNERSHIP_REG_ADDR               'h300
`define OWNERSHIP_FLIP_REG_ADDR          'h304
`define STATUS_RESP_REG_ADDR             'h308
`define INTR_TXN_AVAIL_STATUS_REG_ADDR   'h30C
`define INTR_TXN_AVAIL_CLEAR_REG_ADDR    'h310
`define INTR_TXN_AVAIL_ENABLE_REG_ADDR   'h314
`define STATUS_RESP_COMP_REG_ADDR        'h318
`define STATUS_BUSY_REG_ADDR             'h31C
`define INTR_COMP_STATUS_REG_ADDR        'h320
`define INTR_COMP_CLEAR_REG_ADDR         'h324
`define INTR_COMP_ENABLE_REG_ADDR        'h328
`define RESP_ORDER_REG_ADDR              'h32C
`define RESP_FIFO_FREE_LEVEL_REG_ADDR    'h330

// Descriptor N base = 'h3000 + N*'h200 (verified: desc_1 base = 'h3200)
`define DESC_BASE_ADDR                   'h3000
`define DESC_STRIDE                      'h200
// Per-descriptor field offsets (all verified against slave_all.vh)
`define DESC_TXN_TYPE_OFFSET             'h00
`define DESC_SIZE_OFFSET                 'h04
`define DESC_DATA_OFFSET_OFFSET          'h08
`define DESC_DATA_HOST_ADDR0_OFFSET      'h10   // data_host_addr[0..3] @ 0x10,14,18,1C
`define DESC_WSTRB_HOST_ADDR0_OFFSET     'h20   // wstrb_host_addr[0..3] @ 0x20,24,28,2C
`define DESC_AXSIZE_OFFSET               'h30
`define DESC_ATTR_OFFSET                 'h34
`define DESC_AXADDR0_OFFSET              'h40   // axaddr[0..3] @ 0x40,44,48,4C (4 words)
`define DESC_AXID0_OFFSET                'h50   // axid[0..3] @ 0x50,54,58,5C
`define DESC_AXUSER0_OFFSET              'h60   // axuser[0..15] @ 0x60..0x9C
`define DESC_XUSER0_OFFSET               'hA0   // xuser[0..15] @ 0xA0..0xDC

`define AXI_BRIDGE_MAX_DESC 16

`endif // AXI_BRIDGE_REG_DEFS_SV
