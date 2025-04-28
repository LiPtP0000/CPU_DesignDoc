// 2025.4.28 Add read enable signal to this module
`timescale 1ns / 1ps

module BRAM_INSTR (
           i_clk,
           en_write,
           en_read,
           i_addr_write,
           i_addr_read,
           o_instr_read,
           i_instr_write,
           o_max_addr
       );
input i_clk;
input en_write;                   // flag of write instructions.
input en_read;                    // flag of read instructions.
input [7:0] i_addr_write;         // address of the upcoming instruction
input [15:0] i_instr_write;       // content of the upcoming instruction
input [7:0] i_addr_read;          // address of instruction to be read, starts from 1
output [15:0] o_instr_read;   // content of instruction to be read
output [7:0] o_max_addr;      // current max address of instr BRAM

reg [15:0] mem [0:255];
reg [7:0] current_addr;

always @(posedge i_clk) begin
    if (en_write) begin
        mem[i_addr_write] <= i_instr_write;
        current_addr <= i_addr_write;
    end
end

assign o_instr_read = en_read ? mem[i_addr_read] : 16'b0;   // read fully combinational
assign o_max_addr = current_addr;
endmodule
