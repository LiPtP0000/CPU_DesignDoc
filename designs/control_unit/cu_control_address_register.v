`timescale 1ns / 1ps

module CAR (
    input  wire        clk,            // 时钟
    input  wire [23:0] control_word,   // 微程序控制字
    input  wire [7:0]  ir_data,        // 指令高8位（Opcode）
    input  wire        flag_jump,      // 条件跳转标志（ACC>=0）
    output reg  [7:0]  car_data = 8'h00 // 微指令地址寄存器
);

// 只保留 CAR 控制码（跳转/自增/回0）
wire [1:0] car_ctrl = control_word[21:20];  // 01=跳转; 10=自增; 11=回0

always @(posedge clk) begin
    case (car_ctrl)
        2'b01: begin // 跳转阶段
            case (ir_data)
                8'h01: car_data <= 8'h07; // STORE
                8'h02: car_data <= 8'h09; // LOAD
                8'h03: car_data <= 8'h0B; // ADD
                8'h04: car_data <= 8'h0D; // SUB
                8'h06: car_data <= 8'h0F; // MPY

                8'h07: begin // JGZ（带条件跳转）
                    if (flag_jump) car_data <= 8'h11;
                    else           car_data <= 8'h12;
                end

                8'h08: car_data <= 8'h13; // JMP
                8'h0A: car_data <= 8'h15; // HALT
                8'h0B: car_data <= 8'h17; // AND
                8'h0C: car_data <= 8'h19; // OR
                8'h0D: car_data <= 8'h1B; // NOT

                8'h0E: car_data <= 8'h1D; // SHIFT（建议你拆开左右移）

                default: car_data <= 8'h00; // 异常返回FETCH
            endcase
        end
        2'b10: car_data <= car_data + 1; // 下一个微指令
        2'b11: car_data <= 8'h00;        // 回FETCH第0步
        default: car_data <= car_data;   // 保持不变
    endcase
end

endmodule
