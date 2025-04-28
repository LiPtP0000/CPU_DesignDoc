
module tb_CPU;
    
// UART transmit

// bit period at 115200 baud
parameter bit_period = 8680; // 8.68us, if timescale is 1ns
reg i_rx;
reg cpu_start;
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

initial begin
    i_rx = 1; // idle state high
    cpu_start = 0;
    #(bit_period);

    uart_send_byte(8'b01000001);
    uart_send_byte(8'b00000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b01000001);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b11000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b11000001);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b10000000);
    uart_send_byte(8'b01000000);
    uart_send_byte(8'b00100001);
    uart_send_byte(8'b00100110);
    uart_send_byte(8'b10100000);
    uart_send_byte(8'b00100000);
    uart_send_byte(8'b11100000);
    uart_send_byte(8'b00000000);

    #1000 cpu_start = 1;
    #30000 $finish;
end


// clock generation
reg clk;
initial begin
    clk = 0;
    forever #5 clk = !clk;
end

// Asynchronus reset
reg rst_n;
initial begin
    rst_n = 1;
    #100 rst_n = 0;
    #5 rst_n = 1;
end


// dump
initial begin
    $dumpfile("cpu_0428.vcd");
    $dumpvars(0,tb_CPU);
end

// Instantiate
wire instr_transmit_done;
wire [7:0] max_addr_instr;
wire halt;
wire [15:0] alu_result;
wire [15:0] alu_result_high;
wire [2:0] alu_op;
wire [15:0] alu_P;
wire [15:0] alu_Q;
wire [4:0] flags;

TOP_CPU uut_cpu(
           .i_clk(clk),
           .i_rst_n(rst_n),
           .ctrl_step_execution(1'b0),
           .i_rx(i_rx),
           .i_start_cpu(cpu_start),
           .i_next_instr_stimulus(1'b0),
           .o_instr_transmit_done(instr_transmit_done),
           .o_max_addr(max_addr_instr),
           .o_halt(halt),
           .o_alu_result_low(alu_result),
           .o_alu_result_high(alu_result_high),
           .o_alu_op(alu_op),
           .o_alu_P(alu_P),
           .o_alu_Q(alu_Q),
           .o_flags(flags)
       );
endmodule