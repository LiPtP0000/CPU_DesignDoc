`timescale 1ns / 1ps

module BRAM_INSTR(
    input i_clk,
    input en_write,
    input [7:0] i_addr_write,
    input [15:0] i_instr_write,
    input [7:0] i_addr_read,
    output [15:0] o_instr_read
    );
endmodule
