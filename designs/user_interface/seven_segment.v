`timescale 1ns / 1ps
module SEVEN_SEGMENT #(
           parameter SCAN_INTERVAL = 16'd49999
       ) (
           i_clk,
           i_rst_n,
           i_data,
           o_seg_valid,
           o_seg_value
       );

input i_clk;
input i_rst_n;

input [31:0] i_data;

output reg [7:0] o_seg_valid;
output reg [7:0] o_seg_value;

// Clock Divider
reg [15:0] count_num;
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        count_num <= 3'b0;
    end
    else begin
        if (count_num == SCAN_INTERVAL) begin
            count_num <= 16'd0;
        end
        else begin
            count_num <= count_num + 1'd1;
        end
    end
end

// Segment Select & Polling the segments
reg [2:0] seg_num;
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        seg_num <= 3'b0;
        o_seg_valid <= 8'b0111_1111;
    end
    else begin
        if (count_num == SCAN_INTERVAL) begin
            if (seg_num == 3'd7) begin
                seg_num <= 3'd0;
                o_seg_valid <= 8'b0111_1111;
            end
            else begin
                seg_num <= seg_num + 1'd1;
                o_seg_valid <= {o_seg_valid[0], o_seg_valid[7:1]};
            end
        end
    end
end

// Display Control
reg [4:0] display_value;
always @(*) begin
    // Add Control Logic here to display other things
    case (seg_num)
        3'd0:
            display_value = {1'b0, i_data[31:28]};
        3'd1:
            display_value = {1'b0, i_data[27:24]};
        3'd2:
            display_value = {1'b0, i_data[23:20]};
        3'd3:
            display_value = {1'b0, i_data[19:16]};
        3'd4:
            display_value = {1'b0, i_data[15:12]};
        3'd5:
            display_value = {1'b0, i_data[11:8]};
        3'd6:
            display_value = {1'b0, i_data[7:4]};
        3'd7:
            display_value = {1'b0, i_data[3:0]};
        default:
            display_value = 5'b0;
    endcase
end

// Encoder of 7-segment display
localparam SEG_0 = 8'b1100_0000, SEG_1 = 8'b1111_1001,
          SEG_2 = 8'b1010_0100, SEG_3 = 8'b1011_0000,
          SEG_4 = 8'b1001_1001, SEG_5 = 8'b1001_0010,
          SEG_6 = 8'b1000_0010, SEG_7 = 8'b1111_1000,
          SEG_8 = 8'b1000_0000, SEG_9 = 8'b1001_0000,
          SEG_A = 8'b1000_1000, SEG_B = 8'b1000_0011,
          SEG_C = 8'b1100_0110, SEG_D = 8'b1010_0001,
          SEG_E = 8'b1000_0110, SEG_F = 8'b1000_1110;

// Something else to display
localparam SEG_S = 8'b1011_1111, SEG_r = 8'b1010_1111,
          SEG_o = 8'b1010_0011, SEG_n = 8'b1111_1111,
          SEG_ot =8'b1001_1100, SEG_left = 8'b1111_1100,
          SEG_right = 8'b1101_1110, SEG_happy =8'b1110_0011,
          SEG_sad = 8'b1010_1011;

always @(*) begin
    case (display_value)
        5'd0:
            o_seg_value = SEG_0;
        5'd1:
            o_seg_value = SEG_1;
        5'd2:
            o_seg_value = SEG_2;
        5'd3:
            o_seg_value = SEG_3;
        5'd4:
            o_seg_value = SEG_4;
        5'd5:
            o_seg_value = SEG_5;
        5'd6:
            o_seg_value = SEG_6;
        5'd7:
            o_seg_value = SEG_7;
        5'd8:
            o_seg_value = SEG_8;
        5'd9:
            o_seg_value = SEG_9;
        5'd11:
            o_seg_value = SEG_B;
        5'd10:
            o_seg_value = SEG_A;
        5'd12:
            o_seg_value = SEG_C;
        5'd13:
            o_seg_value = SEG_D;
        5'd14:
            o_seg_value = SEG_E;
        5'd15:
            o_seg_value = SEG_F;
        5'd16:
            o_seg_value = SEG_S;
        5'd17:
            o_seg_value = SEG_r;
        5'd18:
            o_seg_value = SEG_o;
        5'd19:
            o_seg_value = SEG_n;
        5'd20:
            o_seg_value = SEG_ot;
        5'd21:
            o_seg_value = SEG_left;
        5'd22:
            o_seg_value = SEG_right;
        5'd23:
            o_seg_value = SEG_happy;
        5'd24:
            o_seg_value = SEG_sad;
        default:
            o_seg_value = 8'b1;
    endcase
end
endmodule
