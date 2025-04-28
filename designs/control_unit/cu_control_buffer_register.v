`timescale 1ns / 1ps

module CBR (
           ctrl_cpu_start,
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
input ctrl_cpu_start;
input [23:0] memory;
output ctrl_global_halt;  // C23
output ctrl_mar_increment;  // C22
output [1:0] next_addr;  // C21-C20
output [3:0] ALU_op;  // C19-C16
output C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15;

assign C0 = ctrl_cpu_start & memory[0];
assign C1 = ctrl_cpu_start & memory[1];
assign C2 = ctrl_cpu_start & memory[2];
assign C3 = ctrl_cpu_start & memory[3];
assign C4 = ctrl_cpu_start & memory[4];
assign C5 = ctrl_cpu_start & memory[5];
assign C6 = ctrl_cpu_start & memory[6];
assign C7 = ctrl_cpu_start & memory[7];
assign C8 = ctrl_cpu_start & memory[8];
assign C9 = ctrl_cpu_start & memory[9];
assign C10 = ctrl_cpu_start & memory[10];
assign C11 = ctrl_cpu_start & memory[11];
assign C12 = ctrl_cpu_start & memory[12];
assign C13 = ctrl_cpu_start & memory[13];
assign C14 = ctrl_cpu_start & memory[14];
assign C15 = ctrl_cpu_start & memory[15];

assign ALU_op = ctrl_cpu_start ? memory[19:16] : 4'b0;

assign next_addr = ctrl_cpu_start ? memory[21:20] : 2'b0;
assign ctrl_mar_increment = ctrl_cpu_start & memory[22];
assign ctrl_global_halt = ctrl_cpu_start & memory[23];

endmodule
