`timescale 1ns / 1ps

module KEY_JITTER(
           i_clk,
           key_in,
           key_out
       );

input i_clk;
input key_in;
output key_out;

// Counter Max
parameter CNT_MAX = 20'hf_ffff;

reg [1:0] key_in_r;
reg [19:0] cnt_base;
reg key_value_r;
// reg key_value_rd;

// Sample and stage key input
always @(posedge i_clk) begin
    key_in_r <= {key_in_r[0], key_in};
end

// Counter starts if key changes
always @(posedge i_clk) begin
    if (key_in_r[0] != key_in_r[1]) begin
        cnt_base <= 20'b0;
    end
    else if (cnt_base < CNT_MAX) begin
        cnt_base <= cnt_base + 1'b1;
    end
    else if (cnt_base == CNT_MAX) begin
        cnt_base <= 20'b0;
    end
end


always @(posedge i_clk) begin
    if (cnt_base == CNT_MAX) begin
        key_value_r <= key_in_r[0];
    end
end

assign key_out = key_value_r;

endmodule
