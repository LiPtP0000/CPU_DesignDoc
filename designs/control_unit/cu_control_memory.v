`timescale 1ns / 1ps

module control_mem (
    input  wire [7:0] car,            // 控制地址寄存器
    output reg  [23:0] control_word   // 输出控制字（24 位）
);

always @(*) begin
    case (car)
        // FETCH 阶段
        8'h00: control_word = 24'b00100000_00000000_00000100; // IF1
        8'h01: control_word = 24'b00100000_00000000_00100001; // IF2
        8'h02: control_word = 24'b00100000_00000000_00010000; // ID1
        8'h03: control_word = 24'b00100000_00000000_00010000; // ID2

        // 获取操作数地址阶段
        8'h04: control_word = 24'b00010000_00100000_00000000; // FO
        8'h05: control_word = 24'b00100000_00000001_00000000; // IND1
        8'h06: control_word = 24'b00110000_00000000_00100001; // IND2

        // STORE 指令
        8'h07: control_word = 24'b00100000_00000001_00000000; // EX
        8'h08: control_word = 24'b00110000_00010000_01000001; // WB

        // LOAD 指令
        8'h09: control_word = 24'b00100000_00000000_00000000; // EX
        8'h0A: control_word = 24'b00110000_00000000_00010000; // WB

        // ADD 指令
        8'h0B: control_word = 24'b00101000_00000110_00000000; // EX
        8'h0C: control_word = 24'b00111000_00000000_00100000; // WB

        // SUB 指令
        8'h0D: control_word = 24'b00101001_00000110_00000000; // EX
        8'h0F: control_word = 24'b00111001_00000000_00100000; // WB

        // MPY 指令
        8'h10: control_word = 24'b00101010_00000110_00000000; // EX
        8'h11: control_word = 24'b00111010_00000000_01100000; // WB

        // JMPGEZ 指令
        8'h12: control_word = 24'b00100000_00000000_00000100; // EX
        8'h13: control_word = 24'b00110000_00000000_00000000; // WB

        // JUMP 指令
        8'h14: control_word = 24'b00100000_00000000_00000000; // EX
        8'h15: control_word = 24'b00110000_00000000_00000100; // WB

        // HALT 指令
        8'h16: control_word = 24'b00100000_00000000_00000000; // EX
        8'h17: control_word = 24'b00110000_00000000_00000000; // WB

        // AND 指令
        8'h18: control_word = 24'b00101011_00000110_00000000; // EX
        8'h19: control_word = 24'b00111011_00000000_00100000; // WB

        // OR 指令
        8'h1A: control_word = 24'b00101100_00000110_00000000; // EX
        8'h1B: control_word = 24'b00111100_00000000_00100000; // WB

        // NOT 指令
        8'h1C: control_word = 24'b00101101_00000010_00000000; // EX
        8'h1D: control_word = 24'b00111101_00000000_00100000; // WB

        // SHIFTR 指令
        8'h1E: control_word = 24'b00101110_00000110_00000000; // EX
        8'h1F: control_word = 24'b00111110_00000000_00100000; // WB

        // SHIFTL 指令
        8'h20: control_word = 24'b00101111_00000110_00000000; // EX
        8'h21: control_word = 24'b00111111_00000000_00100000; // WB

        default: control_word = 24'b00000000_00000000_00000000; // 默认安全值
    endcase
end

endmodule
