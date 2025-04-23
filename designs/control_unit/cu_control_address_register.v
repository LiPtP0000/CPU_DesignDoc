`timescale 1ns / 1ps

module CAR (
    input  wire        clk,            // 时钟
    input  wire [23:0] control_word,   // 微程序控制字
    input  wire [7:0]  ir_data,        // 指令高8位（Opcode）
    input  wire        flag_jump,      // 条件跳转标志（ACC>=0）
    output reg  [7:0]  car_data = 8'h00 // 控制微指令地址寄存器
);

// 提取 CAR 控制与条件跳转位
wire cond_branch = control_word[23];        // 1=条件跳转
wire [1:0] car_ctrl = control_word[21:20];  // 01=跳转;10=自增;11=回0

always @(posedge clk) begin
    case (car_ctrl)
        2'b01: begin // 微程序跳转阶段
            if (cond_branch) begin
                // 条件跳转指令 JGZ
                if (flag_jump) car_data <= 8'h13; // JMPGEZ 起始
                else          car_data <= 8'h14; // 不跳回下一微指
            end else begin
                // 无条件跳转到对应指令微程序起始地址
                case (ir_data)
                    8'h01: car_data <= 8'h04; // STORE
                    8'h02: car_data <= 8'h07; // LOAD
                    8'h03: car_data <= 8'h0B; // ADD
                    8'h04: car_data <= 8'h0F; // SUB
                    8'h06: car_data <= 8'h13; // JUMP
                    8'h07: car_data <= 8'h15; // HALT
                    8'h08: car_data <= 8'h16; // MPY
                    8'h0A: car_data <= 8'h1E; // AND
                    8'h0B: car_data <= 8'h22; // OR
                    8'h0C: car_data <= 8'h26; // NOT
                    8'h0D: car_data <= 8'h2A; // SLL
                    8'h0E: car_data <= 8'h2D; // SRL
                    default: car_data <= 8'h00; // 回FETCH
                endcase
            end
        end
        2'b10: car_data <= car_data + 1; // 下一个微指令
        2'b11: car_data <= 8'h00;        // 回FETCH第0步
        default: /*2'b00*/ car_data <= car_data; // 保持
    endcase
end

endmodule
