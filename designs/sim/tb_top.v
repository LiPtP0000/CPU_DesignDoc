// Author: LiPtP
// Last modified: 2025.5.5
// This is a testbench to test user interface and CPU.
`timescale 1ns/1ps
module tb_TOP;

// Parameters
parameter bit_period = 8680; // 8.68us, if timescale is 1ns
parameter MAX_DELAY_TOLERANCE = 20'hfff;
parameter SCAN_INTERVAL = 16'd300;
// Registers
reg clk;
reg rst_n;
reg i_rx;
reg cpu_start;
reg next_instr;
reg step_execution;
reg sample_result;
reg sample_instr;
reg sample_flags;

// Wires
// wire instr_transmit_done;
// wire [7:0] max_addr_instr;
// wire halt;

wire [7:0] seg_valid;
wire [7:0] seg_value;
wire RGB1_BLUE;
wire RGB1_RED;
wire RGB2_BLUE;
wire RGB2_RED;
wire RGB2_GREEN;

// Task: Insert random clock delay
task random_clk_delay;
    integer random_time;
    begin
        random_time = 10 + $random % 1000; 
        repeat (random_time) @(posedge clk); 
    end
endtask

// Task: UART send byte
task uart_send_byte(input [7:0] data);
    integer i;
    begin
        // Start bit
        i_rx = 0;
        #(bit_period);
        // Data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            i_rx = data[i];
            #(bit_period);
        end
        // Stop bit
        i_rx = 1;
        #(bit_period);
        // There will be no interval between bytes
    end
endtask

// Clock generation
initial begin
    clk = 0;
    forever
        #5 clk = !clk;
end

// Asynchronous reset
initial begin
    rst_n = 1;
    #100 rst_n = 0;
    repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
    #10
    rst_n = 1;
end

// DumpFile
initial begin
    $dumpfile("top_0504.vcd");
    $dumpvars(0, tb_TOP);
end




// Task: Wait for CPU start
task cpu_start_task;
    begin
        cpu_start = 0;
        step_execution = 1;         // Edit step execution switch here
        wait(RGB2_GREEN);
        #1000 cpu_start = 1;
    end
endtask

// Task: Execute instructions step by step
task execute_instructions;
    begin
        sample_result = 0;
        sample_instr = 0;
        sample_flags = 0;
        next_instr = 0;
        // Wait for CPU to start
        wait(cpu_start == 1);
        repeat (10) @(posedge clk);
        while (!RGB2_RED) begin
            #10 sample_result = 1;
            repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
            #10 sample_result = 0;
            repeat (100) @(posedge clk);
            #10 sample_instr = 1;
            repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
            #10 sample_instr = 0;
            repeat (100) @(posedge clk);
            #10 sample_flags = 1;
            repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
            #10 sample_flags = 0;
            repeat (100) @(posedge clk);
            next_instr = 1;
            repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
            #10 next_instr = 0;
            repeat (100) @(posedge clk);
        end
        $display("CPU halted at %t", $time);
        // $display("ALU result: %h", alu_result);
        // $display("ALU result high: %h", alu_result_high);
    end
endtask

// Task: Check result after auto run
task check_result;
    begin
        sample_flags = 0;
        sample_instr = 0;
        sample_result = 0;
        wait(RGB2_RED);
        $display("CPU halted at %t", $time);
        #10 sample_result = 1;
        repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
        #10 sample_result = 0;
        repeat (100) @(posedge clk);
        #10 sample_instr = 1;
        repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
        #10 sample_instr = 0;
        repeat (100) @(posedge clk);
        #10 sample_flags = 1;
        repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
        #10 sample_flags = 0;
        repeat (100) @(posedge clk);
        next_instr = 1;
        repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
        #10 next_instr = 0;
        repeat (100) @(posedge clk);
        // $display("ALU result: %h", alu_result);
        // $display("ALU result high: %h", alu_result_high);
    end
    
endtask
// Task: Reset and restart CPU, try send some byte again to test robustness
task reset_and_restart_cpu;
    begin
        #1000 cpu_start = 0;
        #1000 rst_n = 0;
        repeat (MAX_DELAY_TOLERANCE + 3) @(posedge clk);
        #10 rst_n = 1;
        random_clk_delay();
        uart_send_byte(8'b01000001);
        uart_send_byte(8'b00000000);
    end
endtask

// Main initial block
initial begin
    cpu_start_task(); 
    if(step_execution) begin
        execute_instructions();
    end else begin
        check_result();
    end
    reset_and_restart_cpu();
    wait(RGB2_GREEN);
    #10000 $finish;
end



TOP #(
        .MAX_DELAY_TOLERANCE(MAX_DELAY_TOLERANCE),
        .SCAN_INTERVAL(SCAN_INTERVAL)
    )uut_cpu_top (
        .CLK_100MHz(clk),            // 时钟信号
        .START_CPU(cpu_start),       // 启动 CPU 信号
        .STEP_EXECUTION(step_execution), // 单步执行信号
        .BTNC(next_instr),           // 中间按钮（下一条指令）
        .BTNL(sample_result),                     // 左按钮（未使用）
        .BTNR(sample_instr),                     // 右按钮（未使用）
        .BTNU(rst_n),                     // 上按钮（复位）
        .BTND(sample_flags),                     // 下按钮（未使用）
        .RXD(i_rx),                  // UART 接收数据
        .SEG_VALID(seg_valid),                // 数码管有效信号（未连接）
        .SEG_VALUE(seg_value),                // 数码管显示值（未连接）
        .RGB1_RED(RGB1_RED),                 // RGB LED 1 红色（未连接）
        .RGB1_BLUE(RGB1_BLUE),                // RGB LED 1 蓝色（未连接）
        .RGB2_RED(RGB2_RED),                 // RGB LED 2 红色（未连接）
        .RGB2_BLUE(RGB2_BLUE),                // RGB LED 2 蓝色（未连接）
        .RGB2_GREEN(RGB2_GREEN)                // RGB LED 2 绿色（未连接）
    );


// RXD Data
initial begin
    i_rx = 1; // idle state high
    wait(rst_n == 0);
    wait(rst_n == 1);
    repeat (2* MAX_DELAY_TOLERANCE ) @(posedge clk);
    #10
    // // Addr 1: LOAD IMMEDIATE 0
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b00000000);
    // // STORE IMMEDIATE 1
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // // LOAD IMMEDIATE 1
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b10000000);
    // // STORE IMMEDIATE 2
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // // LOAD 1
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000000);
    // // ADD 2
    // uart_send_byte(8'b11000000);
    // uart_send_byte(8'b01000000);
    // // STORE IMMEDIATE 1
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // // LOAD 2
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000000);
    // // ADD IMMEDIATE 1
    // uart_send_byte(8'b11000001);
    // uart_send_byte(8'b10000000);
    // // STORE IMMDEDIATE 2
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // // SUB IMMEDIATE 100
    // uart_send_byte(8'b00100001);
    // uart_send_byte(8'b00100110);
    // // STORE 3
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b11000000);
    // // JGZ 5
    // uart_send_byte(8'b10100001);
    // uart_send_byte(8'b10100000);
    // // LOAD IMMEDIATE 1
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000000);
    // // HALT
    // uart_send_byte(8'b11100000);
    // uart_send_byte(8'b00000000);

    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b11111111);
    // uart_send_byte(8'b00010001);
    // uart_send_byte(8'b01111111);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b11111111);
    // uart_send_byte(8'b00010000);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b11000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b11000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b00100000);
    // uart_send_byte(8'b11100000);
    // uart_send_byte(8'b00000000);

    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10110001);
    // uart_send_byte(8'b11110000);
    // uart_send_byte(8'b00110001);
    // uart_send_byte(8'b01010000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10110001);
    // uart_send_byte(8'b11010000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b11100000);
    // uart_send_byte(8'b00000000);

    uart_send_byte(8'b01000001);
    uart_send_byte(8'b00100110);
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b01000001);
    uart_send_byte(8'b11000110);
    uart_send_byte(8'b00100000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b10010001);
    uart_send_byte(8'b00110000);
    uart_send_byte(8'b01010001);
    uart_send_byte(8'b11000000);
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b11010000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b01100001);
    uart_send_byte(8'b11010000);
    uart_send_byte(8'b11000001);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b11100000);
    uart_send_byte(8'b00000000);
end

endmodule
