`timescale 1ns / 1ps

// Sequencing Logic & CAR
/*  Sequencing Logic of CAR
*   10 self increment
*   11 back to 0
*   01 jump 
*   00 nothing
*/
module CAR (
           ctrl_cpu_start,
           ctrl_step_execution,
           i_ctrl_halt,
           i_next_instr_stimulus,
           i_clk,
           i_rst_n,
           i_control_word_car,
           i_ir_data,
           i_ctrl_ZF,
           i_ctrl_NF,
           i_ctrl_MF,
           o_car_data
       );
input wire ctrl_cpu_start;
input wire ctrl_step_execution;
input wire i_clk;
input wire i_rst_n;
input wire i_next_instr_stimulus;
input wire [1:0] i_control_word_car;
input wire [4:0] i_ir_data;  // MSB + IR[3:0]
input wire i_ctrl_ZF;  // ZF Flag
input wire i_ctrl_NF;  // NF Flag
input wire i_ctrl_MF;  // MF Flag
input wire i_ctrl_halt;  // C23
output wire [6:0] o_car_data;

reg ctrl_cpu_start_reg;

always @(posedge i_clk) begin
    ctrl_cpu_start_reg <= ctrl_cpu_start;
end

reg [4:0] ir_data;
reg [6:0] CAR;
reg indirect_done;
wire indirect_flag = ctrl_cpu_start ? (!ir_data[4] && (ir_data[3:0]!= 4'b0)) : 1'b0;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        ir_data <= 5'b0; 
    end
    else begin
        if (i_ir_data[3:0] != 3'b0) begin
            ir_data <= i_ir_data[4:0]; 
        end
    end
end

// always @(*) begin
//     if(i_ir_data[3:0] != 3'b0) begin
//         ir_data = i_ir_data[4:0];
//     end
//     else begin
//         ir_data = ir_data;
//     end
// end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        CAR <= 7'b0;
        indirect_done <= 1'b0;
    end
    else if (ctrl_cpu_start && !ctrl_cpu_start_reg) begin
        CAR <= 7'b0;
    end
    else begin
        case (i_control_word_car)
            2'b01: begin  // Jump to execution or indirect
                // indirect at previlige
                if (indirect_flag && !indirect_done) begin
                    CAR <= 7'h05;
                    indirect_done <= 1'b1;
                end
                else begin
                    case (ir_data[3:0])
                        4'd1: begin
                            if (i_ctrl_MF) begin
                                CAR <= 7'h21;  // STORE & STOREH
                            end
                            else begin
                                CAR <= 7'h07;  // STORE Only
                            end
                        end
                        4'd2:
                            CAR <= 7'h09;  // LOAD
                        4'd3:
                            CAR <= 7'h0B;  // ADD
                        4'd4:
                            CAR <= 7'h0D;  // SUB

                        4'd5: begin  // JGZ
                            if (i_ctrl_ZF || i_ctrl_NF)
                                CAR <= 7'h00;
                            else
                                CAR <= 7'h11;
                        end
                        4'd6:
                            CAR <= 7'h11;     // JMP
                        4'd7:
                            CAR <= 7'h13;     // HALT
                        4'd8:
                            CAR <= 7'h0F;     // MPY
                        4'd9:
                            CAR <= 7'h15;     // AND
                        4'd10:
                            CAR <= 7'h17;    // OR
                        4'd11:
                            CAR <= 7'h19;    // NOT
                        4'd12:
                            CAR <= 7'h1B;    // SHIFTR
                        4'd13:
                            CAR <= 7'h1D;    // SHIFTL
                        default:
                            CAR <= 7'h00;
                    endcase
                end
            end
            2'b10: begin
                CAR <= CAR + 1;  // Next Micro-instruction
            end
            2'b11: begin
                if (i_ctrl_halt) begin
                    // Previliage HALT
                    CAR <= CAR;
                end
                else if (ctrl_step_execution) begin
                    // Step-by-step instruction fetch
                    if (i_next_instr_stimulus) begin
                        CAR    <= 7'h00;
                        indirect_done <= 1'b0;
                    end
                    else begin
                        // NOP WB Stage
                        CAR <= 7'h20;
                    end
                end
                else begin
                    // Auto fetch
                    CAR    <= 7'h00;  // Fetch next instruction
                    indirect_done <= 1'b0;  // Reset Indirect Flag
                end
            end
            default:
                CAR <= CAR;  // Prevent latch
        endcase
    end
end

assign o_car_data = ctrl_cpu_start ? CAR : 7'b0;

endmodule
