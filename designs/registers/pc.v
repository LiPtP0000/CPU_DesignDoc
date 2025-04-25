/*
module PC
Author: LiPtP
function:
1. self increment upon C2
2. write value sequence: MBR
*/
module PC (
    i_clk,
    i_rst_n,
    i_mbr_pc,
    C1,
    C2,
    o_pc_mar,
    o_pc_mbr
);
  input i_clk;
  input i_rst_n;
  input [7:0] i_mbr_pc;
  input C1;
  input C2;
  output [7:0] o_pc_mar;
  output [7:0] o_pc_mbr;

  reg [7:0] PC;

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      PC <= 8'b0;
    end else begin
    // when C2 is open, it must be fetch stage
      if (C2) begin
        PC <= PC + 1;
      end else begin
        PC <= i_mbr_pc ? i_mbr_pc : PC;
      end
    end
  end

  assign o_pc_mbr = C1 ? PC : 8'b0;
  assign o_pc_mar = C2 ? PC : 8'b0;

endmodule
