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
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b00000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b11000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b11000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b10100110);

    // uart_send_byte(8'b00100000);
    // uart_send_byte(8'b01000000);

    // uart_send_byte(8'b10100001);
    // uart_send_byte(8'b10100000);

    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b10000000);

    // uart_send_byte(8'b11100000);
    // uart_send_byte(8'b00000000);
    // mul.txt
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

    // shift.txt
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

    // logic.txt
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b00100110);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b01000001);
    // uart_send_byte(8'b11000110);
    // uart_send_byte(8'b00100000);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b10010001);
    // uart_send_byte(8'b00110000);
    // uart_send_byte(8'b01010001);
    // uart_send_byte(8'b11000000);
    // uart_send_byte(8'b10000001);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b11010000);
    // uart_send_byte(8'b01000000);
    // uart_send_byte(8'b01100001);
    // uart_send_byte(8'b11010000);
    // uart_send_byte(8'b11000001);
    // uart_send_byte(8'b10000000);
    // uart_send_byte(8'b11100000);
    // uart_send_byte(8'b00000000);

    // mul_add.txt
    uart_send_byte(8'b01000001);
uart_send_byte(8'b00010011);
uart_send_byte(8'b00010001);
uart_send_byte(8'b11100000);
uart_send_byte(8'b10000001);
uart_send_byte(8'b00100000);
uart_send_byte(8'b01000001);
uart_send_byte(8'b11111111);
uart_send_byte(8'b00010001);
uart_send_byte(8'b01111111);
uart_send_byte(8'b10000001);
uart_send_byte(8'b10000000);
uart_send_byte(8'b01000001);
uart_send_byte(8'b11111111);
uart_send_byte(8'b00010000);
uart_send_byte(8'b10000000);
uart_send_byte(8'b00100000);
uart_send_byte(8'b00100000);
uart_send_byte(8'b10000001);
uart_send_byte(8'b10100000);
uart_send_byte(8'b01000000);
uart_send_byte(8'b10100000);
uart_send_byte(8'b01000000);
uart_send_byte(8'b01100000);
uart_send_byte(8'b11100000);
uart_send_byte(8'b00000000);
end


// Task: Wait for CPU start
task cpu_start_task;
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
        repeat (10) @(posedge clk);
        while (!halt) begin
            
            #10 user_sample = 1;
            #10 user_sample = 0;
            #10000;
            next_instr = 1;
            #10 next_instr = 0;
            repeat (10) @(posedge clk);    
        end
        $display("CPU halted at %t", $time);
        $display("ALU result: %h", alu_result);
        $display("ALU result high: %h", alu_result_high);
        #10 user_sample = 1;
        #10 user_sample = 0;
        #10000;
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
    cpu_start_task();
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
            .o_flags(flags),
            .o_current_Opcode(current_opcode),
            .o_current_PC(current_pc)
        );

endmodule
