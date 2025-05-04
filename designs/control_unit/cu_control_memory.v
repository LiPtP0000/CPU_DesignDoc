
/*
* 1 global halt
* 1 MAR self increment
* 2 CAR 
* 1 ALU_enable 
* 3 ALU 
* 16 internal bus
* C2: Control for PC+1
* Critical path: STOREH with indirect for 10 clock cycles
*/
`timescale 1ns / 1ps

module CONTROL_MEMORY (
           car,
           control_word
       );
input wire [6:0] car;             // From CAR
output reg [23:0] control_word;   // Output Ctrl Signal

always @(*) begin
    case (car)
        // Instruction
        7'h00:
            control_word = 24'b00_10_0000_00000000_00000100;  // IF1, 2 PC+1
        7'h01:
            control_word = 24'b00_10_0000_00000000_00100001;  // IF2, 0 5
        7'h02:
            control_word = 24'b00_10_0000_00000000_00010000;  // ID1, 4
        7'h03:
            control_word = 24'b00_10_0000_01000000_00000000;  // ID2, 14

        // Operand
        7'h04:
            control_word = 24'b00_01_0000_10000000_00000000;  // FO,   15
        7'h05:
            control_word = 24'b00_10_0000_00000001_00000000;  // IND1, 8
        7'h06:
            control_word = 24'b00_01_0000_00000000_00100001;  // IND2, 0 5

        // STORE
        7'h07:
            control_word = 24'b00_10_0000_00010001_00000000;  // EX, 8 12
        7'h08:
            control_word = 24'b00_11_0000_00100000_00000001;  // WB, 0 13

        // LOAD
        7'h09:
            control_word = 24'b00_10_0000_00000000_00000000;  // EX
        7'h0A:
            control_word = 24'b00_11_0000_00001000_00000000;  // WB, 11

        // ADD
        7'h0B:
            control_word = 24'b00_10_1000_00000000_11000000;  // EX, 6 7
        7'h0C:
            control_word = 24'b00_11_0000_00000010_00000000;  // WB, 9

        // SUB
        7'h0D:
            control_word = 24'b00_10_1001_00000000_11000000;  // EX, 6 7
        7'h0E:
            control_word = 24'b00_11_0001_00000010_00000000;  // WB, 9

        // MPY
        7'h0F:
            control_word = 24'b00_10_1010_00000000_11000000;  // EX, 6 7
        7'h10:
            control_word = 24'b00_11_0010_00000010_00000000;  // WB, 9

        // JGZ & JMP
        7'h11:
            control_word = 24'b00_10_0000_00000000_00000000;  // EX
        7'h12:
            control_word = 24'b00_11_0000_00000000_00001000;  // WB, 3

        // HALT
        // Stop and reset control word to IF
        7'h13:
            control_word = 24'b00_10_0000_00000000_00000000;  // EX
        7'h14:
            control_word = 24'b10_11_0000_00000000_00000000;  // WB, HALT

        // AND
        7'h15:
            control_word = 24'b00_10_1011_00000000_11000000;  // EX, 6 7
        7'h16:
            control_word = 24'b00_11_0011_00000010_00000000;  // WB, 9

        // OR
        7'h17:
            control_word = 24'b00_10_1100_00000000_11000000;  // EX, 6 7
        7'h18:
            control_word = 24'b00_11_0100_00000010_00000000;  // WB, 9

        // NOT
        7'h19:
            control_word = 24'b00_10_1101_00000000_01000000;  // EX, 6
        7'h1A:
            control_word = 24'b00_11_0101_00000010_00000000;  // WB, 9

        // SHIFTR
        7'h1B:
            control_word = 24'b00_10_1110_00000000_11000000;  // EX, 6 7
        7'h1C:
            control_word = 24'b00_11_0110_00000010_00000000;  // WB, 9

        // SHIFTL
        7'h1D:
            control_word = 24'b00_10_1111_00000000_11000000;  // EX, 6 7
        7'h1E:
            control_word = 24'b00_11_0111_00000010_00000000;  // WB, 9

        // Implicit Instructions

        // NOP
        // Used for completing the instruction cycle.
        // Executed if JGZ is judged false.

        7'h1F:
            control_word = 24'b00_10_0000_00000000_00000000;  // EX
        7'h20:
            control_word = 24'b00_11_0000_00000000_00000000;  // WB

        // STOREH (fixed on 25/5/3)
        // Used for storage of high bytes of multiply results.
        // Executed after STORE Operation on MF = 1.

        7'h21:
            control_word = 24'b00_10_0000_00010001_00000000;  // EX1, 8 12
        7'h22:
            control_word = 24'b01_10_0000_00100100_00000001;  // WB1, 0 10 13 MAR+1
        7'h23:
            control_word = 24'b00_10_0000_00010000_00000000;  // EX2, 12
        7'h24:
            control_word = 24'b00_11_0000_00100000_00000001;  // WB2，0 13
        
        default:
            control_word = 24'b00_11_0000_00000000_00000000;  // Back to zero addr
    endcase
end

endmodule
