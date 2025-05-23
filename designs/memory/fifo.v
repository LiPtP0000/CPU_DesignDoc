// Date: 25.4.13
// Author: LiPtP
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

localparam DEPTH = 16;  // FIFO depth, for storing full commands
localparam ADDR_WIDTH = 4;  // Address for FIFO

reg [7:0] fifo_mem[0:DEPTH-1];

reg [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
reg [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

// Read is faster than Write, so we use newer wr_sync pointer
wire fifo_empty = (wr_ptr_gray_sync2 == rd_ptr_gray);
wire fifo_full  = ((rd_ptr_gray[ADDR_WIDTH]     != wr_ptr_gray_sync2[ADDR_WIDTH]) &&
                   (rd_ptr_gray[ADDR_WIDTH-1:0] == wr_ptr_gray_sync2[ADDR_WIDTH-1:0]));

reg clk_wr_d;
wire clk_wr_rising = (clk_wr_d && !i_clk_wr);
always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
        clk_wr_d <= 0;
    end
    else begin
        clk_wr_d <= i_clk_wr;
    end
end
// i_clk_rd is the system clock
always @(posedge i_clk_rd) begin
    if(clk_wr_rising) begin
        if (i_valid_uart && !fifo_full)
            fifo_mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= i_data_uart;
    end
end

// -------------------------------
// Write Time Zone (UART, 1.8432MHz)
// -------------------------------
always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
        wr_ptr_bin  <= 0;
        wr_ptr_gray <= 0;
    end
    else begin
        if(clk_wr_rising) begin
            if (i_valid_uart && !fifo_full) begin
                wr_ptr_bin <= wr_ptr_bin + 1;
                wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
            end
        end
    end
end



// 同步读指针（Gray）到写时钟域
always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
        rd_ptr_gray_sync1 <= 0;
        rd_ptr_gray_sync2 <= 0;
    end
    else begin
        if(clk_wr_rising) begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end
end

// -------------------------------
// Read Clock Zone (CPU, 100MHz)
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
        data_buffer  <= 0;
    end
    else begin
        o_wr_en_bram <= 0;

        // Read a byte to data_buffer if it's odd or write out
        if (!fifo_empty) begin

            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);

            if (!byte_flag) begin
                data_buffer <= fifo_mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
                byte_flag   <= 1;
            end
            else begin
                o_data_bram  <= {data_buffer, fifo_mem[rd_ptr_bin[ADDR_WIDTH-1:0]]};  // opcode + operand
                o_addr_bram  <= o_addr_bram + 1;
                o_wr_en_bram <= 1;
                byte_flag    <= 0;
            end
        end

        //   end else if (byte_flag) begin
        //     // if there are odd bytes from UART, fill zero
        //     o_data_bram  <= {data_buffer, 8'h00};
        //     o_addr_bram  <= o_addr_bram + 1;
        //     o_wr_en_bram <= 1;
        //     byte_flag    <= 0;
        //   end
    end
end

// 同步写指针（Gray）到读时钟域
always @(posedge i_clk_rd or negedge i_rst_n) begin
    if (!i_rst_n) begin
        wr_ptr_gray_sync1 <= 0;
        wr_ptr_gray_sync2 <= 0;
    end
    else begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
end

assign o_fifo_empty = fifo_empty;
endmodule

