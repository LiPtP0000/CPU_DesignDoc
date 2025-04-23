`timescale 1ns / 1ps


module CBR(
    input [23:0]ctrl_memory,
    output C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C20,C21,C22,C23,
    output  [3:0] ctrl_signal    
    );
   assign C0=ctrl_memory[0];
   assign C1=ctrl_memory[1];
   assign C2=ctrl_memory[2];
   assign C3=ctrl_memory[3];
   assign C4=ctrl_memory[4];
   assign C5=ctrl_memory[5];
   assign C6=ctrl_memory[6];
   assign C7=ctrl_memory[7];
   assign C8=ctrl_memory[8];
   assign C9=ctrl_memory[9];
   assign C10=ctrl_memory[10];
   assign C11=ctrl_memory[11];
   assign C12=ctrl_memory[12];
   assign C13=ctrl_memory[13];
   assign C14=ctrl_memory[14];
   assign C15=ctrl_memory[15];
   
   assign ctrl_signal=ctrl_memory[19:16];
   
   assign C20=ctrl_memory[20];
   assign C21=ctrl_memory[21];
   assign C22=ctrl_memory[22];
   assign C23=ctrl_memory[23];
endmodule
