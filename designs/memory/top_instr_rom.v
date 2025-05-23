`timescale 1ns / 1ps

module INSTR_ROM (
           i_clk,
           i_rst_n,
           i_rx,
           en_read,
           i_addr_read,
           o_instr_read,
           o_instr_transmit_done,
           o_max_addr
       );

input i_clk;  // Board Freqency: 100MHz

input i_rst_n;  // Global Reset
input i_rx;
input en_read;  // Read Enable Signal
input [7:0] i_addr_read;
output [15:0] o_instr_read;
output o_instr_transmit_done;
output [7:0] o_max_addr;

// Baud Rate Settings
parameter BAUD_RATE = 115200;
parameter CLK_FREQ = 100000000;

localparam CLK_DIV = CLK_FREQ / BAUD_RATE;

wire valid_uart;
wire [7:0] data_uart;
wire [15:0] data_bram;
wire [7:0] addr_bram;
wire enable_write_bram;
wire clear_uart;
wire clear_fifo;



CLK_DIVIDER #(
                .DIVIDE_BY(CLK_DIV)
            )
            instr_fetch_clk_divide
            (
                .i_clk(i_clk),
                .i_rst_n_sync(i_rst_n),
                .o_clk_div(i_clk_uart)
            );

UART instr_load_uart (
         .i_clk(i_clk),
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
         .i_clk_rd(i_clk),
         .o_data_bram(data_bram),
         .o_addr_bram(addr_bram),
         .o_wr_en_bram(enable_write_bram),
         .o_fifo_empty(clear_fifo)
     );

BRAM_INSTR instr_load_bram (
               .i_clk(i_clk),
               .en_write(enable_write_bram),
               .en_read(en_read),
               .i_addr_write(addr_bram),
               .i_addr_read(i_addr_read),
               .o_instr_read(o_instr_read),
               .i_instr_write(data_bram),
               .o_max_addr(o_max_addr)
           );

// needs fix
assign o_instr_transmit_done = clear_uart & clear_fifo;
endmodule
