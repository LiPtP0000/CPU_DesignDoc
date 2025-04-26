`timescale 1ns / 1ps

module tb_CU_TOP;

// Inputs to the DUT (Device Under Test)
reg i_clk;
reg i_rst_n;
reg [7:0] i_ir_data;
reg [4:0] i_flags;          // ZF, CF, OF, NF, MF
reg ctrl_step_execution;
reg i_next_instr_stimulus;

// Outputs from the DUT
wire [3:0] o_alu_op;
wire o_ctrl_mar_increment;  // C23
wire o_IF_stage;            // C2
wire C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15;

CU_TOP uut (
           .i_clk(i_clk),
           .i_rst_n(i_rst_n),
           .i_flags(i_flags),
           .i_ir_data(i_ir_data),
           .o_alu_op(o_alu_op),
           .o_ctrl_halt(),
           .o_ctrl_mar_increment(o_ctrl_mar_increment),
           .o_IF_stage(o_IF_stage),
           .ctrl_step_execution(ctrl_step_execution),
           .i_next_instr_stimulus(i_next_instr_stimulus),
           .C0(C0),
           .C1(C1),
           .C2(C2),
           .C3(C3),
           .C4(C4),
           .C5(C5),
           .C6(C6),
           .C7(C7),
           .C8(C8),
           .C9(C9),
           .C10(C10),
           .C11(C11),
           .C12(C12),
           .C13(C13),
           .C14(C14),
           .C15(C15)
       );

always begin
    #5 i_clk = ~i_clk;  // Period = 10 ns, 100 MHz clock
end

initial begin
    i_clk = 0;
    i_rst_n = 0;
    i_ir_data = 8'b0;
    i_flags = 5'b0;
    ctrl_step_execution = 0;
    i_next_instr_stimulus = 0;

    #10
     i_rst_n = 1;
    i_ir_data = 8'h1A;
    i_flags = 5'b10100;
    // Single-step mode
    ctrl_step_execution = 1;
    repeat(3) begin               // 3 pulses
        #30 i_next_instr_stimulus = 1;
        #10 i_next_instr_stimulus = 0;
        #300;
    end

    // Continuous Scenario
    #100;
    ctrl_step_execution = 0;
    i_next_instr_stimulus = 1;
    #300;
    i_next_instr_stimulus = 0;

    // Test 2: Change instruction data
    #500 i_ir_data = 8'h2B;  // Another instruction value
    i_flags = 5'b01010;  // Change flags

    // Test 3: Provide another test case
    #500 i_ir_data = 8'h3C;
    i_flags = 5'b11001;  // Change flags again

    // Test 4: Test with other specific values
    #500 i_ir_data = 8'hFF;  // All ones as test instruction
    i_flags = 5'b00001;  // Set flags

    #1000 $finish;
end

initial begin
    $dumpfile("cu_top_tb.vcd");
    $dumpvars(0, tb_CU_TOP);
end

endmodule
