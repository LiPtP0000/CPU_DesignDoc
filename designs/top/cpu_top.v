/*
module CPU_TOP
Author: LiPtP
 
Should instantiate:
1. External Bus
2. Control Unit
3. Internal Registers
4. Memories
and they should be at the same hierarchy level as they explains the whole CPU. 
 
The user interface should acknowledge part of CPU status and provide input to CPU, so it should be at the same level as this module.
 
*/
module TOP_CPU(
           i_clk,
           i_rst_n
       );

input i_clk;
input i_rst_n;


wire [15:0] MBR_MEMORY;
wire [15:0] MEMORY_MBR;
wire [7:0] MAR_MEMORY;
wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15;

EXTERNAL_BUS external_bus(
                 .i_clk(i_clk),
                 .i_rst_n(i_rst_n),
                 .i_mbr_data_bus(MBR_MEMORY),
                 .i_mar_address_bus(MAR_MEMORY),
                 .o_data_bus_memory(MBR_MEMORY),
                 .o_address_bus_memory,
                 .o_data_ram_write,
                 .o_instr_rom_read,
                 .o_data_ram_read,
                 .o_data_ram_write,
                 .C0,
                 .C2,
                 .C5,
                 .C13
             );
DATA_RAM data_ram(
             i_clk,
             i_rst_n,
             ctrl_write,
             i_addr_write,
             i_data_write,
             ctrl_read,
             i_addr_read,
             o_data_read
         );

INSTR_ROM instruction_rom(
              .i_clk_uart,
              .i_rst_n,
              .i_rx,
              .i_addr_read,
              .o_instr_read,
              .o_instr_transmit_done,
              .o_max_addr
          );

REG_TOP internal_registers(
            .i_clk(i_clk),
            .i_rst_n(i_rst_n),
            .i_memory_data,
            .o_memory_addr,
            .o_memory_data,
            .o_ir_cu,
            .o_flags,
            .i_alu_op,
            .i_ctrl_halt,
            .i_ctrl_mar_increment,
            .C0,
            .C1,
            .C2,
            .C3,
            .C4,
            .C5,
            .C6,
            .C7,
            .C8,
            .C9,
            .C10,
            .C11,
            .C12,
            .C13,
            .C14,
            .C15
        );
CU_TOP control_unit(
           .ctrl_step_execution,
           .i_next_instr_stimulus,
           .i_clk,
           .i_rst_n,
           .i_flags,
           .i_ir_data,
           .o_alu_op,
           .o_ctrl_halt,
           .o_IF_stage,
           .o_ctrl_mar_increment,
           .C0,
           .C1,
           .C2,
           .C3,
           .C4,
           .C5,
           .C6,
           .C7,
           .C8,
           .C9,
           .C10,
           .C11,
           .C12,
           .C13,
           .C14,
           .C15
       );
endmodule
