`timescale 1ns / 1ps

module BRAM_INSTR (
    i_clk,
    en_write,
    i_addr_write,
    i_addr_read,
    o_instr_read,
    i_instr_write,
);
  input i_clk;
  input en_write;  // flag of write instructions.
  input [7:0] i_addr_write;  // address of the upcoming instruction
  input [15:0] i_instr_write;  // content of the upcoming instruction
  input [7:0] i_addr_read;  // address of instruction to be read
  output reg [15:0] o_instr_read;  // content of instruction to be read

  reg [15:0] mem [0:255];
  
  always @(posedge i_clk)begin
    if (en_write) begin
        mem[i_addr_write] <= i_instr_write;
    end 
    o_instr_read <= mem[i_addr_read];
  end

endmodule
