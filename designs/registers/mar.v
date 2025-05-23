/*
module MAR
Author: LiPtP
function:
1. self increment upon STOREH implicit instruction
2. write value sequence: MBR > PC
*/
`timescale 1ns / 1ps
module MAR (
           i_clk,
           i_rst_n,
           i_mbr_mar,
           i_pc_mar,
           C2,
           C8,
           ctrl_mar_increment,
           o_mar_address_bus
       );
input i_clk;
input i_rst_n;
input ctrl_mar_increment;
input C2;
input C8;
input [7:0] i_mbr_mar;
input [7:0] i_pc_mar;
output [7:0] o_mar_address_bus;

reg [7:0] MAR;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        MAR <= 8'b0;
    end
    else begin
        if (ctrl_mar_increment) begin
            MAR <= MAR + 1;
        end
        else begin
            if (C8) begin
                MAR <= i_mbr_mar;
            end
            else if (C2) begin
                MAR <= i_pc_mar;
            end
            else begin
                MAR <= MAR;
            end
        end
    end
end

// Address bus judgement logic at reg_top
assign o_mar_address_bus = MAR;
endmodule
