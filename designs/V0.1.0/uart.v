`timescale 1ns / 1ps

module UART (
    input            i_clk,    
    input            i_rst_n,  
    input            i_rx,     // RX input from the serial port
    output reg [7:0] o_data,   // Output data
    output reg       o_valid   // Valid signal
);

  // Baud Rate Settings
  parameter BAUD_RATE = 115200;  // Baud Rate
  parameter CLK_FREQ = 100000000;  // Clock Frequency

  localparam CLK_DIV = CLK_FREQ / BAUD_RATE;

  // State Parameters
  parameter IDLE = 3'b000;
  parameter START = 3'b001;
  parameter DATA = 3'b010;
  parameter STOP = 3'b011;


  reg [2:0] current_state, next_state;

  // Counters
  reg [15:0] clk_div_counter;
  reg [ 3:0] bit_counter;
  // Data Receiver
  reg [ 7:0] rx_shift_reg;

  // State transition & counter
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      current_state   <= IDLE;
      clk_div_counter <= 0;
    end else begin
      current_state <= next_state;
      // Clock Counter
      if (clk_div_counter == CLK_DIV - 1) begin
        clk_div_counter <= 0;
      end else begin
        clk_div_counter <= clk_div_counter + 1;
      end
    end
  end

  // Data receiver from RX
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_valid <= 0;
      o_data <= 8'b0;
      bit_counter <= 0;
      rx_shift_reg <= 8'b0;
    end else begin
      case (current_state)
        IDLE: begin
          if (i_rx == 0) begin  // Wait for start bit 0
            next_state <= START;
          end else begin
            next_state <= IDLE;
          end
          // if no start bit detected in a baud cycle, turn o_valid to 0
          if (clk_div_counter ==CLK_DIV - 1) begin
            o_valid <= 0;
          end
        end

        START: begin
          if (clk_div_counter == CLK_DIV - 1) begin
            next_state   <= DATA;
            bit_counter  <= 0;
            rx_shift_reg <= 0;
          end else begin
            next_state <= START;
          end
        end

        DATA: begin
          if (clk_div_counter == CLK_DIV - 1) begin
            rx_shift_reg <= {i_rx, rx_shift_reg[7:1]};  // descending order
            bit_counter  <= bit_counter + 1;

            if (bit_counter == 7) begin  // receiver done
              next_state <= STOP;
            end else begin
              next_state <= DATA;
            end
          end else begin
            next_state <= DATA;
          end
        end

        STOP: begin
          if (clk_div_counter == CLK_DIV - 1) begin
            if (i_rx == 1) begin  // Stop bit is 1
              o_data  <= rx_shift_reg;
              o_valid <= 1;
            end
            next_state <= IDLE;
          end else begin
            next_state <= STOP;
          end
        end

        default: next_state <= IDLE;
      endcase
    end
  end

endmodule
