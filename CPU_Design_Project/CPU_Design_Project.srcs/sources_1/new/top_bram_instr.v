`timescale 1ns / 1ps

module INIT_INSTR_BRAM (
    i_clk_uart,
    i_clk,
    i_rst_n,
    i_rx,
    i_addr_read,
    o_instr_read
);
  input i_clk_uart;     // Board Freqency: 100MHz
  input i_clk;          // CPU Frequency: 50MHz
  input i_rst_n;        // Global Reset

  wire valid_uart;
  wire [7:0] data_uart;
  wire [15:0] data_bram;
  wire [7:0] addr_bram;
  wire enable_write_bram;

  UART instr_load_uart (
      .i_clk_uart(i_clk_uart),
      .i_rst_n(i_rst_n),
      .i_rx(i_rx),
      .o_data(data_uart),
      .o_valid(valid_uart)
  );

  FIFO instr_load_fifo (
      .i_rst_n(i_rst_n),
      .i_clk_wr(i_clk_uart),
      .i_valid_uart(valid_uart),
      .i_data_uart(data_uart),
      .i_clk_rd(i_clk),
      .o_data_bram(data_bram),
      .o_addr_bram(addr_bram),
      .o_wr_en_bram(enable_write_bram)
  );

  BRAM_INSTR instr_load_bram (
      .i_clk(i_clk),
      .en_write(enable_write_bram),
      .i_addr_write(addr_bram),
      .i_addr_read(i_addr_read),
      .o_instr_read(o_instr_read)
  );
  
endmodule
