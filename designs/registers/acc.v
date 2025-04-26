module ACC (
           i_clk,
           i_rst_n,
           i_br_acc,
           i_mr_acc,
           i_mbr_acc,
           C7,
           C12,
           o_acc_alu_p,
           o_acc_mbr
       );
input i_clk;
input i_rst_n;
input [15:0] i_br_acc;
input [15:0] i_mr_acc;
input [15:0] i_mbr_acc;
input C7;
input C12;
output [15:0] o_acc_alu_p;
output [15:0] o_acc_mbr;

reg [15:0] ACC;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        ACC <= 16'b0;
    end
    else begin
        if (i_br_acc != 16'b0) begin
            ACC <= i_br_acc;
        end
        else if (i_mr_acc != 16'b0) begin
            ACC <= i_mr_acc;
        end
        else if (i_mbr_acc != 16'b0) begin
            ACC <= i_mbr_acc;
        end

        else begin
            ACC <= ACC;
        end
    end
end

assign o_acc_alu_p = C7 ? ACC : 16'b0;
assign o_acc_mbr   = C12 ? ACC : 16'b0;
endmodule
