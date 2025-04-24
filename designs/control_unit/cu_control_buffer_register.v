`timescale 1ns / 1ps

module CBR (
    memory,
    ctrl_global_halt,
    ctrl_mar_increment,
    next_addr,
    ALU_op,
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
  input [23:0] memory;
  output ctrl_global_halt;  // C23
  output ctrl_mar_increment;  // C22
  output [1:0] next_addr;  // C21-C20
  output [3:0] ALU_op;  // C19-C16
  output C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15;

  assign C0 = memory[0];
  assign C1 = memory[1];
  assign C2 = memory[2];
  assign C3 = memory[3];
  assign C4 = memory[4];
  assign C5 = memory[5];
  assign C6 = memory[6];
  assign C7 = memory[7];
  assign C8 = memory[8];
  assign C9 = memory[9];
  assign C10 = memory[10];
  assign C11 = memory[11];
  assign C12 = memory[12];
  assign C13 = memory[13];
  assign C14 = memory[14];
  assign C15 = memory[15];

  assign ALU_op = memory[19:16];

  assign next_addr = memory[21:20];
  assign ctrl_mar_increment = memory[22];
  assign ctrl_global_halt = memory[23];

endmodule
