`timescale 1ns / 1ps

// Sequencing Logic & CAR
/*  Sequencing Logic of CAR 
*   10 self increment
*   11 back to 0
*   01 jump 
*   00 nothing
*/
module CAR (
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
  output reg [6:0] o_car_data;

  // Indicator of indirect cycle requirement
  wire indirect_flag = i_ir_data[4];

  // Indicator of indirect cycle done, default 0.
  reg indirect_done;


  wire [3:0] ir_data = i_ir_data[3:0];

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_car_data <= 7'h00;
      indirect_done <= 1'b0;
    end else begin
      // indirect at previlige
      if (indirect_flag && !indirect_done) begin
        o_car_data <= 7'h02;
        indirect_done <= 1'b1;
      end else begin
        case (i_control_word_car)
          2'b01: begin  // Jump to execution
            case (ir_data)
              4'd1: begin
                if (i_ctrl_MF) begin
                  o_car_data <= 7'h23;  // STORE & STOREH
                end else begin
                  o_car_data <= 7'h07;  // STORE Only
                end
              end
              4'd2: o_car_data <= 7'h09;  // LOAD
              4'd3: o_car_data <= 7'h0B;  // ADD
              4'd4: o_car_data <= 7'h0D;  // SUB

              4'd5: begin  // JGZ
                if (!i_ctrl_ZF && !i_ctrl_NF) o_car_data <= 7'h11;
                else o_car_data <= 7'h00;
              end
              4'd6: o_car_data <= 7'h11;     // JMP
              4'd7: o_car_data <= 7'h13;     // HALT
              4'd8: o_car_data <= 7'h0F;     // MPY
              4'd9: o_car_data <= 7'h15;     // AND
              4'd10: o_car_data <= 7'h17;    // OR
              4'd11: o_car_data <= 7'h19;    // NOT
              4'd12: o_car_data <= 7'h1B;    // SHIFTR
              4'd13: o_car_data <= 7'h1D;    // SHIFTL
              default: o_car_data <= 7'h00;
            endcase
          end
          2'b10: begin
            o_car_data <= o_car_data + 1;  // Next Micro-instruction
          end
          2'b11: begin
            if (i_ctrl_halt) begin
              // Previliage HALT
              o_car_data <= o_car_data;
            end else if (ctrl_step_execution) begin
              // Step-by-step instruction fetch
              if (i_next_instr_stimulus) begin
                o_car_data    <= 7'h00;
                indirect_done <= 1'b0;
              end else begin
                o_car_data <= o_car_data;
              end
            end else begin
              // Auto fetch
              o_car_data    <= 7'h00;  // Fetch next instruction
              indirect_done <= 1'b0;  // Reset Indirect Flag
            end
          end
          default: o_car_data <= o_car_data;  // Prevent latch
        endcase
      end
    end
  end

endmodule
