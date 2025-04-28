/*
module TOP
Author: LiPtP
 
Should instantiate:
1. CPU
2. User Interface
 
This is the very top module of the CPU.
* New ideas on 4.29 3.A.M
1. When in STEP mode, instantiate a button to fetch specified Register Value. Use switches to decide the displayed register. 
2. When in AUTO mode, show ACC value and MR value on HALT (optional).
*/
module  TOP(
            // Should only declare signals from/to the board
            // and they are directly assigned to physical ports via constraint files.

        );

wire clk;

wire switch_step_execution;     // using a switch resource
wire switch_start_cpu;
wire button_rst_n;
wire button_next_instr;

wire light_instr_transmit_done;
wire [4:0] light_flags;
wire light_halt;

wire [7:0] segment_max_instr_addr;
wire [15:0] segment_operand_P;
wire [15:0] segment_operand_Q;
wire [15:0] segment_result_low;
wire [15:0] segment_result_high;
wire [2:0] segment_operation;

wire rx;
TOP_CPU cpu (
            .i_clk(clk),
            .i_rst_n(button_rst_n),
            .ctrl_step_execution(switch_step_execution),
            .i_rx(rx),
            .i_start_cpu(switch_start_cpu),
            .i_next_instr_stimulus(button_next_instr),
            .o_instr_transmit_done(light_instr_transmit_done),
            .o_max_addr(segment_max_instr_addr),
            .o_halt(light_halt),
            .o_alu_result_low(segment_result_low),
            .o_alu_result_high(segment_result_high),
            .o_alu_op(segment_operation),
            .o_alu_P(segment_operand_P),
            .o_alu_Q(segment_operand_Q),
            .o_flags(light_flags)
        );
// =========================== User Interfaces ===============================

// Signals prefixed "segment" should be instantiated here


// Signals prefixed "light" should be instantiated here


// Signals prefixed "switch" should be instantiated here


// Signals prefixed "button" should be instantiated here

// ============================ Assignments ==================================

// UART input should be connected here.

endmodule
