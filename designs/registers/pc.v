/*
module PC
Author: LiPtP
function:
1. self increment upon C2
2. write value sequence: MBR
3. PC starts from 1 (0428 updated)
*/
module PC (
           i_clk,
           i_rst_n,
           i_mbr_pc,
           C1,
           C2,
           C3,
           o_pc_mar,
           o_pc_mbr,
           i_user_sample,
           o_pc_user
       );
input i_clk;
input i_rst_n;
input i_user_sample;
input [7:0] i_mbr_pc;
input C1;
input C2;
input C3;
output [7:0] o_pc_mar;
output [7:0] o_pc_mbr;
output [7:0] o_pc_user;
reg [7:0] PC;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        PC <= 8'd1;
    end
    else begin
        // when C2 is open, it must be fetch stage
        if (C2) begin
            PC <= PC + 1;
        end
        else begin
            PC <= C3 ? i_mbr_pc : PC;
        end
    end
end

assign o_pc_mbr = C1 ? PC : 8'b0;
assign o_pc_mar = C2 ? PC : 8'b0;
assign o_pc_user = i_user_sample ? PC : 8'b0;
endmodule
