`timescale 1ns/1ps
module tb_CPU;

// Parameters
parameter bit_period = 8680; // 8.68us, if timescale is 1ns

// Registers
reg i_rx;
reg cpu_start;
reg next_instr;
reg user_sample;
reg clk;
reg rst_n;

// Wires
wire instr_transmit_done;
wire [7:0] max_addr_instr;
wire halt;
wire [15:0] alu_result;
wire [15:0] alu_result_high;
wire [2:0] alu_op;
wire [15:0] alu_P;
wire [15:0] alu_Q;
wire [4:0] flags;
wire [7:0] current_opcode;
wire [7:0] current_pc;

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
    #5 rst_n = 1;
end

// DumpFile
initial begin
    $dumpfile("cpu_0428.vcd");
    $dumpvars(0, tb_CPU);
end

// RXD Data
initial begin
    i_rx = 1; // idle state high
    #(bit_period);
    // Addr 1: LOAD IMMEDIATE 0
    uart_send_byte(8'b01000001);
    uart_send_byte(8'b00000000);
    // STORE IMMEDIATE 1
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b10000000);
    // LOAD IMMEDIATE 1
    uart_send_byte(8'b01000001);
    uart_send_byte(8'b10000000);
    // STORE IMMEDIATE 2
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b01000000);
    // LOAD 1
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b10000000);
    // ADD 2
    uart_send_byte(8'b11000000);
    uart_send_byte(8'b01000000);
    // STORE IMMEDIATE 1
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b10000000);
    // LOAD 2
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b01000000);
    // ADD IMMEDIATE 1
    uart_send_byte(8'b11000001);
    uart_send_byte(8'b10000000);
    // STORE IMMDEDIATE 2
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b01000000);
    // SUB IMMEDIATE 100
    uart_send_byte(8'b00100001);
    uart_send_byte(8'b00100110);
    // STORE 3
    uart_send_byte(8'b10000001);
    uart_send_byte(8'b11000000);
    // JGZ 5
    uart_send_byte(8'b10100001);
    uart_send_byte(8'b10100000);
    // LOAD IMMEDIATE 1
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b10000000);
    // HALT
    uart_send_byte(8'b11100000);
    uart_send_byte(8'b00000000);
end


// Task: Wait for CPU start
task cpu_start;
    begin
        cpu_start = 0;
        wait(instr_transmit_done);
        #1000 cpu_start = 1;
    end
endtask

// Task: Execute instructions
task execute_instructions;
    begin
        user_sample = 0;
        wait(cpu_start == 1);
        #1000;
        while (!halt) begin
            next_instr = 1;
            #10 next_instr = 0;
            #10000;
            #10 user_sample = 1;
            #10 user_sample = 0;
        end
        $display("CPU halted at %t", $time);
        $display("ALU result: %h", alu_result);
        $display("ALU result high: %h", alu_result_high);
    end
endtask

// Task: Reset and restart CPU
task reset_and_restart_cpu;
    begin
        #1000 cpu_start = 0;
        #1000 rst_n = 0;
        #10 rst_n = 1;
        #(bit_period);
        uart_send_byte(8'b01000001);
        uart_send_byte(8'b00000000);
    end
endtask

// Main initial block
initial begin
    cpu_start();
    execute_instructions();
    reset_and_restart_cpu();
    wait(instr_transmit_done);
    #10000 $finish;
end




TOP_CPU uut_cpu(
            .i_clk(clk),
            .i_rst_n(rst_n),
            .ctrl_step_execution(1'b1),
            .i_user_sample(user_sample),
            .i_rx(i_rx),
            .i_start_cpu(cpu_start),
            .i_next_instr_stimulus(next_instr),
            .o_instr_transmit_done(instr_transmit_done),
            .o_max_addr(max_addr_instr),
            .o_halt(halt),
            .o_alu_result_low(alu_result),
            .o_alu_result_high(alu_result_high),
            .o_alu_op(alu_op),
            .o_flags(flags),
            .o_current_Opcode(current_opcode),
            .o_current_PC(current_pc)
        );
        
endmodule
