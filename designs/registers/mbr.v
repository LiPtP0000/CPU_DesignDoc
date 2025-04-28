/*
module MBR
Author: LiPtP
function:
1. write value sequence: Bus > IR > PC > ACC
*/
`timescale 1ns / 1ps
module MBR (
           i_clk,
           i_rst_n,
           i_pc_mbr,
           i_ir_mbr,
           i_data_bus_mbr,
           i_acc_mbr,
           o_mbr_data_bus,
           o_mbr_pc,
           o_mbr_ir,
           o_mbr_mar,
           o_mbr_acc,
           o_mbr_alu_q,
           C1,
           C3,
           C4,
           C5,
           C6,
           C8,
           C11,
           C12,
           C15
       );
input i_clk;
input i_rst_n;
input [7:0] i_pc_mbr;
input [7:0] i_ir_mbr;
input [15:0] i_data_bus_mbr;
input [15:0] i_acc_mbr;
input C1;
input C3;
input C4;
input C5;
input C6;
input C8;
input C11;
input C12;
input C15;
output [15:0] o_mbr_data_bus;
output [7:0] o_mbr_pc;

// IR stages the storage of MBR on ID Stage, in order that MBR can directly receive immaculate operand on immediate addressing.
output [15:0] o_mbr_ir;

output [7:0] o_mbr_mar;
output [15:0] o_mbr_acc;
output [15:0] o_mbr_alu_q;

reg [15:0] MBR;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        MBR <= 16'b0;
    end
    else begin
        if (C5) begin
            MBR <= i_data_bus_mbr;
        end
        else if (C15) begin
            MBR <= {8'b0, i_ir_mbr};
        end
        else if (C1) begin
            MBR <= {8'b0, i_pc_mbr};
        end
        else if (C12) begin
            MBR <= i_acc_mbr;
        end
        else begin
            MBR <= MBR;
        end
    end
end

assign o_mbr_acc = C11 ? MBR : 16'b0;

assign o_mbr_alu_q = C6 ? MBR : 16'b0;
assign o_mbr_ir = C4 ? MBR : 16'b0;
assign o_mbr_mar = C8 ? MBR[7:0] : 8'b0;
assign o_mbr_pc = C3 ? MBR[7:0] : 8'b0;

// Data bus judgement logic at reg_top
assign o_mbr_data_bus = MBR;

endmodule
