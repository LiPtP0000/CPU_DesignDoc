`timescale 1ns / 1ps
// 5.5 Update: adapt 8N1 format
// 5.6 Update: always module driven by i_clk rather than i_clk_uart
module UART (
           i_clk,
           i_clk_uart,
           i_rst_n,
           i_rx,
           o_data,
           o_valid,
           o_clear_sign
       );
input  wire       i_clk;
input  wire       i_clk_uart;
input  wire       i_rst_n;
input  wire       i_rx;
output reg  [7:0] o_data;
output reg        o_valid;        // on data is translated
output wire       o_clear_sign;   // on no more data is received

// 0.5s no new data
parameter MAX_WAITING_CLK = 434;


// parameter IDLE  = 3'b000;
parameter START = 2'b00;
parameter DATA  = 2'b01;
parameter STOP  = 2'b10;

reg [1:0] current_state, next_state;

reg [2:0] bit_counter;            // At most 8bit data
reg [25:0] rx_no_data_counter;    // time-out counter
reg [7:0] rx_shift_reg;           // data storage

reg clear;
reg i_clk_uart_dly;
wire i_clk_uart_rising = (i_clk_uart && !i_clk_uart_dly);


always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        i_clk_uart_dly <= 0;
    else
        i_clk_uart_dly <= i_clk_uart;
end

// data storage update
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        current_state <= START;
    end
    else begin
        if(i_clk_uart_rising) begin
            current_state <= next_state;
        end
    end
end

// State Shift
always @(*) begin
    case (current_state)
        START:
            next_state = (i_rx == 1'b0) ? DATA : START;
        DATA:
            next_state = (bit_counter == 7) ? STOP : DATA;
        STOP:
            next_state = START;
        default:
            next_state = START;
    endcase
end

// 数据接收与控制逻辑
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        bit_counter   <= 0;
        rx_shift_reg  <= 8'd0;
        o_valid       <= 0;
        o_data        <= 8'd0;
    end
    else begin
        if(i_clk_uart_rising) begin
            case (current_state)
                START: begin
                    bit_counter <= 0;
                    o_valid <= 0;
                    rx_shift_reg <= 0;
                end
                DATA: begin
                    // LSB first
                    rx_shift_reg <= {rx_shift_reg[6:0],i_rx};
                    bit_counter <= bit_counter + 1;
                end
                STOP: begin
                    o_data  <= rx_shift_reg;
                    o_valid <= 1'b1;

                end
                default: begin
                    o_valid <= 0;
                end
            endcase
        end
    end
end

// Time-out detect
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        clear <= 0;
        rx_no_data_counter <= 0;
    end
    else begin
        if(i_clk_uart_rising) begin
            case (current_state)
                START: begin
                    if (rx_no_data_counter == MAX_WAITING_CLK) begin
                        rx_no_data_counter <= 0;
                        clear <= 1;
                    end
                    else begin
                        rx_no_data_counter <= rx_no_data_counter + 1;
                    end
                end
                default: begin
                    clear <= 0;
                    rx_no_data_counter <= 0;
                end
            endcase
        end
    end
end

assign o_clear_sign = clear;

endmodule
