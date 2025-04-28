/*
module CPU_TOP
Author: LiPtP
 
Should instantiate:
1. External Bus
2. Control Unit
3. Internal Registers
4. Memories
and they should be placed at the same hierarchy level as they explains the whole CPU. 
 
The user interface should acknowledge part of CPU status and provide input to CPU, so it should be at the same level as this module.
 
*/
module TOP_CPU(
           i_clk,
           i_rst_n,
           ctrl_step_execution,
           i_rx,
           i_start_cpu,
           i_next_instr_stimulus,
           o_instr_transmit_done,
           o_max_addr,
           o_halt,
           o_alu_result_low,
           o_alu_result_high,
           o_alu_op,
           o_alu_P,
           o_alu_Q,
           o_flags
       );

input i_clk;
input i_rst_n;

// from/to user interface
input ctrl_step_execution;
input i_next_instr_stimulus;
input i_rx;
input i_start_cpu; // start CPU execution
output o_instr_transmit_done;
output [7:0] o_max_addr;
output o_halt; // CPU halt signal
output [2:0] o_alu_op; // ALU operation code
output [4:0] o_flags; // ALU flags

// not implemented on REG_TOP module

output [15:0] o_alu_P; // ALU P register
output [15:0] o_alu_Q; // ALU Q register
output [15:0] o_alu_result_low;
output [15:0] o_alu_result_high;

// external bus
wire [15:0] MBR_DATA_BUS;
wire [15:0] DATA_BUS_MBR;
wire [15:0] DATA_BUS_MEMORY;
wire [15:0] INSTR_MEMORY_DATA_BUS;
wire [15:0] DATA_MEMORY_DATA_BUS;
wire [7:0] MAR_ADDR_BUS;
wire [7:0] ADDR_BUS_MEMORY;
wire en_write_to_instr;
wire en_write_to_data;
wire en_read_from_data;
wire en_read_from_instr;

// internal registers & CU
wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15;
wire [4:0] flags;
wire [7:0] opcode;
wire [3:0] alu_op;
wire [15:0] ALU_P;
wire [15:0] ALU_Q;
wire [15:0] ALU_RES_LOW;
wire [15:0] ALU_RES_HIGH;
wire halt;
wire mar_increment;


EXTERNAL_BUS external_bus(
                 .i_clk(i_clk),
                 .i_rst_n(i_rst_n),
                 .i_mbr_data_bus(MBR_DATA_BUS),
                 .i_mar_address_bus(MAR_ADDR_BUS),
                 .o_data_bus_memory(DATA_BUS_MEMORY),
                 .o_address_bus_memory(ADDR_BUS_MEMORY),
                 .o_data_ram_write(en_write_to_data),
                 .o_instr_rom_read(en_read_from_instr),
                 .o_data_ram_read(en_read_from_data),
                 .C0(C0),
                 .C2(C2),
                 .C5(C5),
                 .C13(C13),
                 .i_instr(INSTR_MEMORY_DATA_BUS),
                 .i_data(DATA_MEMORY_DATA_BUS),
                 .o_data_bus_mbr(DATA_BUS_MBR)

             );
DATA_RAM data_ram(
             .i_clk(i_clk),
             .i_rst_n(i_rst_n),
             .ctrl_write(en_write_to_data),
             .i_addr_write(ADDR_BUS_MEMORY),
             .i_data_write(DATA_BUS_MEMORY),
             .ctrl_read(en_read_from_data),
             .i_addr_read(ADDR_BUS_MEMORY),
             .o_data_read(DATA_MEMORY_DATA_BUS)
         );


INSTR_ROM instruction_rom(
              .i_clk(i_clk),
              .i_rst_n(i_rst_n),
              .i_rx(i_rx),
              .en_read(en_read_from_instr),
              .i_addr_read(ADDR_BUS_MEMORY),
              .o_instr_read(INSTR_MEMORY_DATA_BUS),
              .o_instr_transmit_done(o_instr_transmit_done),
              .o_max_addr(o_max_addr)
          );

REG_TOP internal_registers(
            .ctrl_cpu_start(i_start_cpu),
            .i_clk(i_clk),
            .i_rst_n(i_rst_n),
            .i_memory_data(DATA_BUS_MBR),
            .o_memory_addr(MAR_ADDR_BUS),
            .o_memory_data(MBR_DATA_BUS),
            .o_ir_cu(opcode),
            .o_alu_P(ALU_P),
            .o_alu_Q(ALU_Q),
            .o_alu_result_low(ALU_RES_LOW),
            .o_alu_result_high(ALU_RES_HIGH),
            .o_flags(flags),
            .i_alu_op(alu_op),
            .i_ctrl_halt(halt),
            .i_ctrl_mar_increment(mar_increment),
            .C0(C0),
            .C1(C1),
            .C2(C2),
            .C3(C3),
            .C4(C4),
            .C5(C5),
            .C6(C6),
            .C7(C7),
            .C8(C8),
            .C9(C9),
            .C10(C10),
            .C11(C11),
            .C12(C12),
            .C13(C13),
            .C14(C14),
            .C15(C15)
        );

CU_TOP control_unit(
           .ctrl_cpu_start(i_start_cpu),
           .ctrl_step_execution(ctrl_step_execution),
           .i_next_instr_stimulus(i_next_instr_stimulus),
           .i_clk(i_clk),
           .i_rst_n(i_rst_n),
           .i_flags(flags),
           .i_ir_data(opcode),
           .o_alu_op(alu_op),
           .o_ctrl_halt(halt),
           .o_IF_stage(),
           .o_ctrl_mar_increment(mar_increment),
           .C0(C0),
           .C1(C1),
           .C2(C2),
           .C3(C3),
           .C4(C4),
           .C5(C5),
           .C6(C6),
           .C7(C7),
           .C8(C8),
           .C9(C9),
           .C10(C10),
           .C11(C11),
           .C12(C12),
           .C13(C13),
           .C14(C14),
           .C15(C15)
       );

// Assignments

assign o_halt = halt;
assign o_flags = flags;
assign o_alu_op = alu_op[2:0];      // The highest bit is enable signal
assign o_alu_P = ALU_P;
assign o_alu_Q = ALU_Q;
assign o_alu_result_low = ALU_RES_LOW;
assign o_alu_result_high = ALU_RES_HIGH;
endmodule
