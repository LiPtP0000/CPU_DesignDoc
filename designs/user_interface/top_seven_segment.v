module SEVEN_SEGMENT_DISPLAY #(
           parameter SCAN_INTERVAL = 16'd49999
       ) (
           i_clk,
           i_rst_n,
           switch_start_cpu,
           button_check_instruction,
           button_check_flags,
           button_check_result,
           light_instr_transmit_done,
           segment_current_PC,
           segment_current_Opcode,
           segment_flags,
           segment_result_high,
           segment_result_low,
           segment_max_instr_addr,
           o_seg_valid,
           o_seg_value
       );
input i_clk;
input i_rst_n;
input [7:0] segment_current_PC;
input [7:0] segment_current_Opcode;
input [4:0] segment_flags;
input [15:0] segment_result_high;
input [15:0] segment_result_low;
input [7:0] segment_max_instr_addr;
input button_check_instruction;
input button_check_flags;
input button_check_result;
input light_instr_transmit_done;
input switch_start_cpu;
output [7:0] o_seg_valid;
output [7:0] o_seg_value;

reg [31:0] segment_data;

// 状态定义
localparam STATE_DEFAULT = 3'b000;
localparam STATE_INSTRUCTION = 3'b001;
localparam STATE_FLAGS = 3'b010;
localparam STATE_RESULT = 3'b011;
localparam STATE_MAX_ADDR = 3'b100;

reg [2:0] current_state, next_state;

// 状态机：状态切换逻辑
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        current_state <= STATE_DEFAULT;
    end
    else begin
        current_state <= next_state;
    end
end

// 状态机：下一状态逻辑
always @(*) begin
    case (current_state)
        STATE_DEFAULT: begin
            if (button_check_instruction) begin
                next_state = STATE_INSTRUCTION;
            end
            else if (button_check_flags) begin
                next_state = STATE_FLAGS;
            end
            else if (button_check_result) begin
                next_state = STATE_RESULT;
            end
            else if (light_instr_transmit_done && !switch_start_cpu) begin
                next_state = STATE_MAX_ADDR;
            end
            else begin
                next_state = STATE_DEFAULT;
            end
        end
        STATE_INSTRUCTION: begin
            if (!button_check_instruction) begin
                next_state = STATE_DEFAULT;
            end
            else begin
                next_state = STATE_INSTRUCTION;
            end
        end
        STATE_FLAGS: begin
            if (!button_check_flags) begin
                next_state = STATE_DEFAULT;
            end
            else begin
                next_state = STATE_FLAGS;
            end
        end
        STATE_RESULT: begin
            if (!button_check_result) begin
                next_state = STATE_DEFAULT;
            end
            else begin
                next_state = STATE_RESULT;
            end
        end
        STATE_MAX_ADDR: begin
            if (!(light_instr_transmit_done && !switch_start_cpu)) begin
                next_state = STATE_DEFAULT;
            end
            else begin
                next_state = STATE_MAX_ADDR;
            end
        end
        default: begin
            next_state = STATE_DEFAULT;
        end
    endcase
end

// 状态机：输出逻辑
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        segment_data <= 32'b0;
    end
    else begin
        case (current_state)
            STATE_DEFAULT: begin
                segment_data <= segment_data;
            end
            STATE_INSTRUCTION: begin
                segment_data <= {8'b0, segment_current_PC, 8'b0, segment_current_Opcode};
            end
            STATE_FLAGS: begin
                segment_data <= {15'b0,segment_flags[4],3'b0,segment_flags[3],3'b0,segment_flags[2],3'b0,segment_flags[1],3'b0,segment_flags[0]};
            end
            STATE_RESULT: begin
                segment_data <= {segment_result_high, segment_result_low};
            end
            STATE_MAX_ADDR: begin
                segment_data <= {24'b0, segment_max_instr_addr};
            end
            default: begin
                segment_data <= 32'b0;
            end
        endcase
    end
end

SEVEN_SEGMENT #(
                  .SCAN_INTERVAL(SCAN_INTERVAL)
              ) seven_segment (
                  .i_clk(i_clk),
                  .i_rst_n(i_rst_n),
                  .i_data(segment_data),
                  .o_seg_valid(o_seg_valid),
                  .o_seg_value(o_seg_value)
              );
endmodule
