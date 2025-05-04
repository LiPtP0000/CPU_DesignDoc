`timescale 1ns/1ps
module tb_TOP;

// Parameters
parameter bit_period = 8680; // 8.68us, if timescale is 1ns
parameter MAX_DELAY_TOLERANCE = 3;
parameter SCAN_INTERVAL = 16'd500;
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
        i_rx = 1;
        #(bit_period);
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
    repeat (10) @(posedge clk);
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
        step_execution = 0;
        wait(RGB2_GREEN);
        #100000 cpu_start = 1;
    end
endtask

// Task: Execute instructions
task execute_instructions;
    begin
        sample_result = 0;
        wait(cpu_start == 1);
        repeat (10) @(posedge clk);
        while (!RGB2_RED) begin
            #10 sample_result = 1;
            repeat (10) @(posedge clk);
            #10 sample_result = 0;
            repeat (100) @(posedge clk);
            #10 sample_instr = 1;
            repeat (10) @(posedge clk);
            #10 sample_instr = 0;
            repeat (100) @(posedge clk);
            #10 sample_flags = 1;
            repeat (10) @(posedge clk);
            #10 sample_flags = 0;
            repeat (100) @(posedge clk);
            next_instr = 1;
            #10 next_instr = 0;
            repeat (10) @(posedge clk);
        end
        $display("CPU halted at %t", $time);
        // $display("ALU result: %h", alu_result);
        // $display("ALU result high: %h", alu_result_high);
    end
endtask
// Task: Check result
task check_result;
    begin
        sample_flags = 0;
        sample_instr = 0;
        sample_result = 0;
        if (RGB2_RED) begin
            $display("CPU halted at %t", $time);
            repeat (100) @(posedge clk);
            #10 sample_result = 1;
            repeat (10) @(posedge clk);
            #10 sample_result = 0;
            repeat (10000) @(posedge clk);
            #10 sample_instr = 1;
            repeat (10) @(posedge clk);
            #10 sample_instr = 0;
            repeat (10000) @(posedge clk);
            #10 sample_flags = 1;
            repeat (10) @(posedge clk);
            #10 sample_flags = 0;
            repeat (10000) @(posedge clk);
            // $display("ALU result: %h", alu_result);
            // $display("ALU result high: %h", alu_result_high);
        end
    end
endtask
// Task: Reset and restart CPU
task reset_and_restart_cpu;
    begin
        #1000 cpu_start = 0;
        #1000 rst_n = 0;
        #100 rst_n = 1;
        #(bit_period);
        uart_send_byte(8'b01000001);
        uart_send_byte(8'b00000000);
    end
endtask

// Main initial block
initial begin
    cpu_start_task();
    // execute_instructions();
    
    wait(RGB2_RED);
    check_result();
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
    #1000;
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
