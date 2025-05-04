/*
module TOP
Author: LiPtP
 
Should instantiate:
1. CPU
2. User Interface
 
This is the very top module of the CPU.
* New ideas on 4.29 3.A.M
1. When in STEP mode, instantiate a button to fetch specified Register Value. Use switches to decide the displayed register. 
2. When in AUTO mode, show ACC value and MR value on HALT (optional).
*/
module  TOP #(
            parameter MAX_DELAY_TOLERANCE = 20'hfffff,
            parameter SCAN_INTERVAL = 16'd30000
        )(
            // Should only declare signals from/to the board
            // and they are directly assigned to physical ports via constraint files.
            CLK_100MHz,
            START_CPU,
            STEP_EXECUTION,
            BTNC,
            BTNL,
            BTNR,
            BTNU,
            BTND,
            RXD,
            SEG_VALID,
            SEG_VALUE,
            RGB1_RED,
            RGB1_BLUE,
            RGB2_RED,
            RGB2_BLUE,
            RGB2_GREEN
        );

input CLK_100MHz;
input START_CPU;
input STEP_EXECUTION;
input BTNL;
input BTND;
input BTNR;
input BTNU;
input BTNC;
input RXD;
output [7:0] SEG_VALID;
output [7:0] SEG_VALUE;
output RGB1_RED;
output RGB1_BLUE;
output RGB2_RED;
output RGB2_BLUE;
output RGB2_GREEN;

// ============================ Wires =======================================
wire clk = CLK_100MHz;

wire switch_step_execution;     // using a switch resource
wire switch_start_cpu;
wire button_rst;
wire button_rst_n = !button_rst;
wire button_next_instr;
wire button_check_result;
wire button_check_instruction;
wire button_check_flags;
wire user_sample = button_check_flags | button_check_instruction | button_check_result;

wire light_instr_transmit_done;   // RGB2 Green
wire light_halt;                  // RGB2 Red
wire light_cpu_running;             // RGB2 Blue
wire light_cpu_step;              // RGB1 Red
wire light_cpu_auto;              // RGB1 Blue

// This will show at cpu_start = 0
wire [7:0] segment_max_instr_addr;
wire [7:0] segment_current_PC;
wire [7:0] segment_current_Opcode;
wire [15:0] segment_result_low;
wire [15:0] segment_result_high;
wire [4:0] segment_flags;

wire rx = RXD;
// ============================ Instantiations ===============================
TOP_CPU cpu (
            .i_clk(clk),
            .i_rst_n(button_rst_n),
            .ctrl_step_execution(switch_step_execution),
            .i_user_sample(user_sample),
            .i_rx(rx),
            .i_start_cpu(switch_start_cpu),
            .i_next_instr_stimulus(button_next_instr),
            .o_instr_transmit_done(light_instr_transmit_done),
            .o_max_addr(segment_max_instr_addr),
            .o_halt(light_halt),
            .o_alu_result_low(segment_result_low),
            .o_alu_result_high(segment_result_high),
            .o_flags(segment_flags),
            .o_current_Opcode(segment_current_Opcode),
            .o_current_PC(segment_current_PC)
        );
// =========================== User Interfaces ===============================

// Signals prefixed "switch" should be instantiated here
KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b0)
            ) ins_switch_start_cpu(
               .i_clk(clk),
               .key_in(START_CPU),
               .key_out(switch_start_cpu)
           );
KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b0)
            ) ins_switch_step_execution(
               .i_clk(clk),
               .key_in(STEP_EXECUTION),
               .key_out(switch_step_execution)
           );

// Signals prefixed "button" should be instantiated here
KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b1)
            ) ins_button_reset (
               .i_clk(clk),
               .key_in(BTNU),
               .key_out(button_rst)
           );

KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b1)
            ) ins_button_next_instr(
               .i_clk(clk),
               .key_in(BTNC),
               .key_out(button_next_instr)
           );

KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b1)
            ) ins_button_check_result(
               .i_clk(clk),
               .key_in(BTNL),
               .key_out(button_check_result)
           );

KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b1)
            ) ins_button_check_instruction(
               .i_clk(clk),
               .key_in(BTNR),
               .key_out(button_check_instruction)
           );

KEY_JITTER #(   .CNT_MAX(MAX_DELAY_TOLERANCE),
                .POSEDGE(1'b1)
            ) ins_button_check_flags(
               .i_clk(clk),
               .key_in(BTND),
               .key_out(button_check_flags)
           );

// Signals prefixed "segment" should be instantiated here
SEVEN_SEGMENT_DISPLAY #(
           .SCAN_INTERVAL(SCAN_INTERVAL)
) segment_display (
           .i_clk(clk),
           .i_rst_n(button_rst_n),
           .switch_start_cpu(switch_start_cpu),
           .button_check_instruction(button_check_instruction),
           .button_check_flags(button_check_flags),
           .button_check_result(button_check_result),
           .light_instr_transmit_done(light_instr_transmit_done),
           .segment_current_PC(segment_current_PC),
           .segment_current_Opcode(segment_current_Opcode),
           .segment_flags(segment_flags),
           .segment_result_high(segment_result_high),
           .segment_result_low(segment_result_low),
           .segment_max_instr_addr(segment_max_instr_addr),
           .o_seg_valid(SEG_VALID),
           .o_seg_value(SEG_VALUE)
       );

// Signals prefixed "light" should be instantiated here

LED_DISPLAY led_display(
            .i_clk(clk),
            .i_rst_n(button_rst_n),
            .i_instr_transmit_done(light_instr_transmit_done),
            .i_halt(light_halt),
            .i_step_execution(switch_step_execution),
            .i_start_cpu(switch_start_cpu),
            .RGB1_RED(RGB1_RED),
            .RGB1_BLUE(RGB1_BLUE),
            .RGB2_RED(RGB2_RED),
            .RGB2_BLUE(RGB2_BLUE),
            .RGB2_GREEN(RGB2_GREEN)
        );

// ============================ End of Module ================================
endmodule
