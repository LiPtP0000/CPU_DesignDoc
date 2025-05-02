module ACC (
           i_clk,
           i_rst_n,
           i_br_acc,
           i_mr_acc,
           i_mbr_acc,
           C7,
           C9,
           C10,
           C11,
           C12,
           o_acc_alu_p,
           o_acc_mbr,
           i_user_sample,
           o_acc_user
       );
input i_clk;
input i_rst_n;
input [15:0] i_br_acc;
input [15:0] i_mr_acc;
input [15:0] i_mbr_acc;
input C7;
input C9;
input C10;
input C11;
input C12;
input i_user_sample;
output [15:0] o_acc_alu_p;
output [15:0] o_acc_mbr;
output [15:0] o_acc_user;
reg [15:0] ACC;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        ACC <= 16'b0;
    end
    else begin
        if (C9) begin
            ACC <= i_br_acc;
        end
        else if (C10) begin
            ACC <= i_mr_acc;
        end
        else if (C11) begin
            ACC <= i_mbr_acc;
        end
        else begin
            ACC <= ACC;
        end
    end
end

assign o_acc_alu_p = C7 ? ACC : 16'b0;
assign o_acc_mbr = C12 ? ACC : 16'b0;
assign o_acc_user = i_user_sample ? ACC : 16'b0;
endmodule
