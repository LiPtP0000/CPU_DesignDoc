`timescale 1ns / 1ps

module UART (
    i_clk_uart,
    i_rst_n,
    i_rx,
    o_data,
    o_valid,
    o_clear_sign
);

  input i_clk_uart;
  input i_rst_n;
  input i_rx;  // RX input from the serial port
  output reg [7:0] o_data;  // Output data
  output reg o_valid;  // Valid signal
  output o_clear_sign;
  // Baud Rate Settings
  parameter BAUD_RATE = 115200;
  parameter CLK_FREQ = 100000000;

  localparam CLK_DIV = CLK_FREQ / BAUD_RATE;

  // 0.5s with 100MHz Freqency
  parameter MAX_WAITING_CLK = 50000000;

  // State Parameters
  parameter IDLE = 3'b000;
  parameter START = 3'b001;
  parameter DATA = 3'b010;
  parameter STOP = 3'b011;


  reg [2:0] current_state, next_state;

  // Counters
  reg [15:0] clk_div_counter;
  reg [ 4:0] bit_counter;
  reg [25:0] rx_no_data_counter;
  // Data Receiver
  reg [ 7:0] rx_shift_reg;

  // registers of clear flag
  reg clear, clear_state;

  // State transition & counter
  always @(posedge i_clk_uart or negedge i_rst_n) begin
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
  // State Transitions
  always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n) begin
      current_state <= IDLE;
      next_state <= IDLE;
    end else begin
      case (current_state)
        IDLE: begin
          if (i_rx == 0) begin
            next_state <= START;
          end else begin
            next_state <= IDLE;
          end
        end
        START: begin
          next_state <= DATA;
        end
        DATA: begin
          if (bit_counter == 9) next_state <= STOP;
          else next_state <= DATA;

        end
        STOP: begin
          if (clk_div_counter == CLK_DIV - 1) begin
            next_state <= IDLE;
          end
        end
        default: next_state <= IDLE;
      endcase
    end

  end

  // Data receiver from RX
  always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n) begin

      clk_div_counter <= 0;
      bit_counter <= 0;
      rx_shift_reg <= 8'd0;
      o_valid <= 0;
      o_data <= 8'd0;

    end else begin
      if (clk_div_counter == CLK_DIV >> 1 && current_state == DATA) begin
        rx_shift_reg <= {rx_shift_reg[6:0], i_rx};
      end

      if (clk_div_counter == CLK_DIV - 1) begin
        case (current_state)
          IDLE: begin
            bit_counter <= 0;
          end
          START: begin
            bit_counter <= 0;
          end

          DATA: begin
            bit_counter <= bit_counter + 1;
          end

          STOP: begin
            if (i_rx == 1) begin
              o_data  <= rx_shift_reg;
              o_valid <= 1;
            end
          end
        endcase
      end else begin
        // make sure it only takes one byte
        o_valid <= 0;
      end
    end
  end


  // Assignments
  // activates when a transmission is over and 0.5s past with no more transmission begins.
  always @(posedge i_clk_uart or negedge i_rst_n) begin
    if (!i_rst_n) begin
      clear <= 0;
      clear_state <= 0;
      rx_no_data_counter <= 0;
    end else begin
      case (current_state)
        IDLE: begin
          // Counter of IDLE
          if (rx_no_data_counter == MAX_WAITING_CLK) begin
            rx_no_data_counter <= 0;
            clear <= 1;
          end else begin
            rx_no_data_counter <= rx_no_data_counter + 1;
          end
        end
        // At least a byte is read
        default: begin
          clear_state <= 1;
          clear <= 0;
        end
      endcase
    end
  end
  assign o_clear_sign = clear & clear_state;


endmodule
