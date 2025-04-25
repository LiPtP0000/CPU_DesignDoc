// The top module of the CU
// Author: LiPtP
// Date: 2025.4.25
// Should be connected to:
// * All internal registers via Internal Bus
// * ALU
// * External Bus

module CU_TOP (
    ctrl_step_execution,
    i_next_instr_stimulus,
    i_clk,
    i_rst_n,
    i_flags,
    i_ir_data,
    o_alu_op,
    o_ctrl_halt,
    o_IF_stage,
    o_ctrl_mar_increment,
    C0,
    C1,
    C2,
    C3,
    C4,
    C5,
    C6,
    C7,
    C8,
    C9,
    C10,
    C11,
    C12,
    C13,
    C14,
    C15
);

  // External signals
  input ctrl_step_execution;
  input i_next_instr_stimulus;
  input i_clk;
  input i_rst_n;
  input [7:0] i_ir_data;
  input [4:0] i_flags;  // ZF, CF, OF, NF, MF 

  output [3:0] o_alu_op;
  output o_ctrl_mar_increment;  // C23
  output o_IF_stage;  // C2
  output o_ctrl_halt;  // C23
  output C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15;

  // Internal signals

  wire [ 1:0] next_addr;
  wire [ 6:0] car_data;
  wire [23:0] control_word;


  CAR control_CAR (
      .ctrl_step_execution(ctrl_step_execution),
      .i_next_instr_stimulus(i_next_instr_stimulus),
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_control_word_car(next_addr),
      .i_ir_data({i_ir_data[7], i_ir_data[3:0]}),
      .i_ctrl_ZF(i_flags[4]),
      .i_ctrl_NF(i_flags[1]),
      .i_ctrl_MF(i_flags[0]),
      .i_ctrl_halt(o_ctrl_halt),
      .o_car_data(car_data)
  );

  CONTROL_MEMORY control_memory (
      .car(car_data),
      .control_word(control_word)
  );

  CBR control_CBR (
      .memory(control_word),
      .ctrl_global_halt(o_ctrl_halt),
      .ctrl_mar_increment(o_ctrl_mar_increment),
      .next_addr(next_addr),
      .ALU_op(o_alu_op),
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


  // Assignments

  assign o_IF_stage = C2;

endmodule
