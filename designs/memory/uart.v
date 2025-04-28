`timescale 1ns / 1ps

module UART (
           i_clk_uart,
           i_rst_n,
           i_rx,
           o_data,
           o_valid,
           o_clear_sign
       );
input  wire       i_clk_uart;
input  wire       i_rst_n;
input  wire       i_rx;
output reg  [7:0] o_data;
output reg        o_valid;        // on data is translated
output wire       o_clear_sign;   // on no more data is received

// 0.3ms with 100MHz Frequency => 0.5s / (10ns * MAX_WAITING_CLK)
parameter MAX_WAITING_CLK = 30000;


parameter IDLE  = 3'b000;
parameter START = 3'b001;
parameter DATA  = 3'b010;
parameter STOP  = 3'b011;

reg [2:0] current_state, next_state;

reg [4:0] bit_counter;            // At most 8bit data + start/stop
reg [25:0] rx_no_data_counter;    // time-out counter
reg [7:0] rx_shift_reg;           // data storage

reg clear, clear_state;

// data storage update
always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// 状态转移逻辑
always @(*) begin
    case (current_state)
        IDLE:
            next_state = (i_rx == 1'b0) ? START : IDLE;
        START:
            next_state = DATA;
        DATA:
            next_state = (bit_counter == 8) ? STOP : DATA;
        STOP:
            next_state = IDLE;
        default:
            next_state = IDLE;
    endcase
end

// 数据接收与控制逻辑
always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n) begin
        bit_counter   <= 0;
        rx_shift_reg  <= 8'd0;
        o_valid       <= 0;
        o_data        <= 8'd0;
    end
    else begin
        case (next_state)
            IDLE: begin
                bit_counter <= 0;
                o_valid <= 0;
                rx_shift_reg <= 0;
            end
            START: begin
                bit_counter <= 0;
                o_valid <= 0;
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

// 空闲超时检测
always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n) begin
        clear <= 0;
        clear_state <= 0;
        rx_no_data_counter <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                if (rx_no_data_counter >= MAX_WAITING_CLK) begin
                    rx_no_data_counter <= 0;
                    clear <= 1;
                end
                else begin
                    rx_no_data_counter <= rx_no_data_counter + 1;
                    clear <= 0;
                end
            end
            default: begin
                clear_state <= 1;
                clear <= 0;
                rx_no_data_counter <= 0;
            end
        endcase
    end
end

assign o_clear_sign = clear & clear_state;

endmodule
