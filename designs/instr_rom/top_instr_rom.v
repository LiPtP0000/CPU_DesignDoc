`timescale 1ns / 1ps

module INSTR_ROM (
    i_clk_uart,
    i_rst_n,
    i_rx,
    i_addr_read,
    o_instr_read,
    o_instr_transmit_done,
    o_max_addr
);
  input i_clk_uart;  // Board Freqency: 100MHz

  input i_rst_n;  // Global Reset
  input i_rx;
  input [7:0] i_addr_read;
    output [15:0] o_instr_read;
  output o_instr_transmit_done;
    output [7:0] o_max_addr;
  

  wire valid_uart;
  wire [7:0] data_uart;
  wire [15:0] data_bram;
  wire [7:0] addr_bram;
  wire enable_write_bram;
  wire clear_uart;
  wire clear_fifo;

  // CPU Frequency: 50MHz
  // If we use 100MHz read clk, the UART will fail
  // Sync Reset
  wire clk;

  CLK_DIVIDER instr_load_clk_divide(
    .i_clk(i_clk_uart),
    .i_rst_n_sync(i_rst_n),
    .o_clk_div(clk)
  );

  UART instr_load_uart (
      .i_clk_uart(i_clk_uart),
      .i_rst_n(i_rst_n),
      .i_rx(i_rx),
      .o_data(data_uart),
      .o_valid(valid_uart),
      .o_clear_sign(clear_uart)
  );

  FIFO instr_load_fifo (
      .i_rst_n(i_rst_n),
      .i_clk_wr(i_clk_uart),
      .i_valid_uart(valid_uart),
      .i_data_uart(data_uart),
      .i_clk_rd(clk),
      .o_data_bram(data_bram),
      .o_addr_bram(addr_bram),
      .o_wr_en_bram(enable_write_bram),
      .o_fifo_empty(clear_fifo)
  );

  BRAM_INSTR instr_load_bram (
      .i_clk(clk),
      .en_write(enable_write_bram),
      .i_addr_write(addr_bram),
      .i_addr_read(i_addr_read),
      .o_instr_read(o_instr_read),
      .i_instr_write(data_bram),
      .o_max_addr(o_max_addr)
  );

  assign o_instr_transmit_done = clear_uart & clear_fifo;
endmodule
