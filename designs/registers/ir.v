/*
module IR
Author: LiPtP
function:
1. dump high 8 bits to CU
2. store immediate opcode and operand from MBR and push back operand on FO stage
*/
module IR (
           i_clk,
           i_rst_n,
           i_mbr_ir,
           C14,
           C15,
           o_ir_cu,
           o_ir_mbr
       );

input i_clk;
input i_rst_n;
input [15:0] i_mbr_ir;
input C14;
input C15;
output [7:0] o_ir_cu;
output [7:0] o_ir_mbr;

reg [7:0] IR_opcode;
reg [7:0] IR_operand;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        IR_opcode <= 8'b0;
        IR_operand <= 8'b0;
    end
    else begin
        IR_operand <= (i_mbr_ir[7:0] != 8'b0) ? i_mbr_ir[7:0] : IR_operand;
        IR_opcode <= (i_mbr_ir[15:8] != 8'b0) ? i_mbr_ir[15:8] : IR_opcode;
    end
end

assign o_ir_cu = C14 ? IR_opcode : 8'b0;
assign o_ir_mbr = C15 ? IR_operand : 8'b0;
endmodule
