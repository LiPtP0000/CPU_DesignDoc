// Date: 25.4.13
// Author: LiPtP
// Description
`timescale 1ns / 1ps
module FIFO (
    i_rst_n,
    i_clk_wr,
    i_valid_uart,
    i_data_uart,
    i_clk_rd,
    o_data_bram,
    o_addr_bram,
    o_wr_en_bram,
    o_fifo_empty
);
  input i_rst_n;

  // UART（100MHz）
  input i_clk_wr;
  input i_valid_uart;
  input [7:0] i_data_uart;

  // CPU（50MHz）
  input i_clk_rd;
  output reg [15:0] o_data_bram;
  output reg [7:0] o_addr_bram;
  output reg o_wr_en_bram;

  // for judging completion
  output o_fifo_empty;

  localparam DEPTH = 16;  // FIFO depth
  localparam ADDR_WIDTH = 4;  // Address for FIFO

  reg [7:0] fifo_mem[0:DEPTH-1];

  reg [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
  reg [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
  reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
  reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

  wire fifo_empty = (rd_ptr_gray_sync2 == wr_ptr_gray);
  wire fifo_full  = ((wr_ptr_gray[ADDR_WIDTH]     != rd_ptr_gray_sync2[ADDR_WIDTH]) &&
                       (wr_ptr_gray[ADDR_WIDTH-1:0] == rd_ptr_gray_sync2[ADDR_WIDTH-1:0]));

  // -------------------------------
  // Write Time Zone (UART, 100MHz)
  // -------------------------------
  always @(posedge i_clk_wr or negedge i_rst_n) begin
    if (!i_rst_n) begin
      wr_ptr_bin  <= 0;
      wr_ptr_gray <= 0;
    end else if (i_valid_uart && !fifo_full) begin
      fifo_mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= i_data_uart;
      wr_ptr_bin <= wr_ptr_bin + 1;
      wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
    end
  end

  // 同步读指针（Gray）到写时钟域
  always @(posedge i_clk_wr or negedge i_rst_n) begin
    if (!i_rst_n) begin
      rd_ptr_gray_sync1 <= 0;
      rd_ptr_gray_sync2 <= 0;
    end else begin
      rd_ptr_gray_sync1 <= rd_ptr_gray;
      rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
  end

  // -------------------------------
  // Read Clock Zone (CPU, 50MHz)
  // -------------------------------
  reg [7:0] data_buffer;
  reg       byte_flag;  // flag of the first UART byte is read

  always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
      rd_ptr_bin   <= 0;
      rd_ptr_gray  <= 0;
      byte_flag    <= 0;
      o_data_bram  <= 0;
      o_addr_bram  <= 0;
      o_wr_en_bram <= 0;
    end else begin
      o_wr_en_bram <= 0;

      // Read a byte to data_buffer if it's odd or write out
      if (!fifo_empty) begin

        rd_ptr_bin  <= rd_ptr_bin + 1;
        rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);

        if (!byte_flag) begin
          data_buffer <= fifo_mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
          byte_flag   <= 1;
        end else begin
          o_data_bram  <= {data_buffer, fifo_mem[rd_ptr_bin[ADDR_WIDTH-1:0]]};  // 高字节在前
          o_addr_bram  <= o_addr_bram + 1;
          o_wr_en_bram <= 1;
          byte_flag    <= 0;
        end

      end else if (byte_flag) begin
        // if there are odd bytes from UART, fill zero
        o_data_bram  <= {data_buffer, 8'h00};
        o_addr_bram  <= o_addr_bram + 1;
        o_wr_en_bram <= 1;
        byte_flag    <= 0;
      end
    end
  end

  // 同步写指针（Gray）到读时钟域
  always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
      wr_ptr_gray_sync1 <= 0;
      wr_ptr_gray_sync2 <= 0;
    end else begin
      wr_ptr_gray_sync1 <= wr_ptr_gray;
      wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
  end

  assign o_fifo_empty = fifo_empty;
endmodule

