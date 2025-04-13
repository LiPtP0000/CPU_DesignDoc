// Author: Guangyu Feng
`timescale 1ns/1ps

module tb_INIT_INSTR_BRAM;

  reg clk_uart = 0;
  reg clk_cpu = 0;
  reg rst_n = 0;
  reg i_rx = 0;
  reg [7:0] i_addr_read = 8'd0;

  wire [15:0] o_instr_read;
  wire o_instr_transmit_done;

  // 实例化顶层模块
  INIT_INSTR_BRAM uut (
    .i_clk_uart(clk_uart),
    .i_clk(clk_cpu),
    .i_rst_n(rst_n),
    .i_rx(i_rx),
    .i_addr_read(i_addr_read),
    .o_instr_read(o_instr_read),
    .o_instr_transmit_done(o_instr_transmit_done)
  );

  // UART 时钟 100MHz（10ns周期）
  always #5 clk_uart = ~clk_uart;

  // CPU 时钟 50MHz（20ns周期）
  always #10 clk_cpu = ~clk_cpu;

  initial begin
    $display("Start Simulation");
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_INIT_INSTR_BRAM);

    rst_n = 0;
    #100;
    rst_n = 1;

    // 模拟 UART 接收一组数据（如：0xA5）
    send_uart_byte(8'hA5);
    send_uart_byte(8'h5A);
    send_uart_byte(8'h3C);
    send_uart_byte(8'h2B);
    send_uart_byte(8'h10);

    // 切换地址读取，看看是否成功写入
    #2000;
    i_addr_read = 8'd0;
    #2000;
    i_addr_read = 8'd1;

    #2000;
    i_addr_read = 8'd2;

    #3000;
    $display("End Simulation");
    $finish;
  end

  // UART协议模拟发送函数（8位+1起始位+1停止位）
  task send_uart_byte(input [7:0] data);
    integer i;
    begin
      // 起始位
      i_rx = 0;  #(8680); 
      // 8数据位
      for (i = 0; i < 8; i = i + 1) begin
        i_rx = data[i];
        #(8680);
      end
      // 停止位
      i_rx = 1;  #(8680);
      // 发送完成后保持
      #(86800); // 间隔
    end
  endtask

endmodule
