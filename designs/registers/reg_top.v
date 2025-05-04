/*
module REG_TOP
Author: LiPtP
 
Should be connected with:
1. External Bus
2. Control Unit
and they should be at the same hierarchy level.
*/
module REG_TOP(
           ctrl_cpu_start,
           i_user_sample,
           o_ACC_user,
           o_MR_user,
           o_PC_user,
           o_IR_user,
           i_clk,
           i_rst_n,
           i_memory_data,
           o_memory_addr,
           o_memory_data,
           o_ir_cu,
           o_flags,
           i_alu_op,
           i_ctrl_halt,
           i_ctrl_mar_increment,
           C1,
           C2,
           C3,
           C4,
           C5,
           C6,
           C7,
           C8,
           C9,
           C10,
           C11,
           C12,
           C14,
           C15
       );

input ctrl_cpu_start;
input i_user_sample;
input i_clk;
input i_rst_n;
// From External Bus
input [15:0] i_memory_data;

// From Control Unit
input [3:0] i_alu_op; // C19 - C16
input i_ctrl_halt;    // C23
input i_ctrl_mar_increment; // C22
input  C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C14, C15;

// To External Bus
output [7:0] o_memory_addr;
output [15:0] o_memory_data;

// To Control Unit
output [7:0] o_ir_cu;
output [4:0] o_flags;

// To User Interface
output [15:0] o_ACC_user;
output [15:0] o_MR_user;
output [7:0] o_PC_user;
output [7:0] o_IR_user;

// Internal signals (16 Data Path)

wire [7:0] MAR_ADDR_BUS;    // C0
wire [7:0] PC_MBR;          // C1
wire [7:0] PC_MAR;          // C2
wire [7:0] MBR_PC;          // C3
wire [15:0] MBR_IR;         // C4
wire [15:0] DATA_BUS_MBR;   // C5
wire [15:0] MBR_ALU_Q;      // C6
wire [15:0] ACC_ALU_P;      // C7
wire [7:0] MBR_MAR;         // C8
wire [15:0] BR_ACC;         // C9
wire [15:0] MR_ACC;         // C10
wire [15:0] MBR_ACC;        // C11
wire [15:0] ACC_MBR;        // C12
wire [15:0] MBR_DATA_BUS;   // C13
wire [7:0] IR_CU;           // C14
wire [7:0] IR_MBR;          // C15

// Instantiate the registers

ACC reg_ACC(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_br_acc(BR_ACC),
        .i_mr_acc(MR_ACC),
        .i_mbr_acc(MBR_ACC),
        .C7(C7),
        .C9(C9),
        .C10(C10),
        .C11(C11),
        .C12(C12),
        .o_acc_alu_p(ACC_ALU_P),
        .o_acc_mbr(ACC_MBR),
        .i_user_sample(i_user_sample),
        .o_acc_user(o_ACC_user)
    );

// The first command in CM is open C2
PC reg_PC(
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
       .i_mbr_pc(MBR_PC),
       .C1(C1),
       .C2(C2 & ctrl_cpu_start),
       .C3(C3),
       .o_pc_mar(PC_MAR),
       .o_pc_mbr(PC_MBR),
       .i_user_sample(i_user_sample),
       .o_pc_user(o_PC_user)
   );
MBR reg_MBR(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_pc_mbr(PC_MBR),
        .i_ir_mbr(IR_MBR),
        .i_data_bus_mbr(DATA_BUS_MBR),
        .i_acc_mbr(ACC_MBR),
        .o_mbr_data_bus(MBR_DATA_BUS),
        .o_mbr_pc(MBR_PC),
        .o_mbr_ir(MBR_IR),
        .o_mbr_mar(MBR_MAR),
        .o_mbr_acc(MBR_ACC),
        .o_mbr_alu_q(MBR_ALU_Q),
        .C1(C1),
        .C3(C3),
        .C4(C4),
        .C5(C5),
        .C6(C6),
        .C8(C8),
        .C11(C11),
        .C12(C12),
        .C15(C15)
    );

MAR reg_MAR(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_mbr_mar(MBR_MAR),
        .i_pc_mar(PC_MAR),
        .ctrl_mar_increment(i_ctrl_mar_increment),
        .o_mar_address_bus(MAR_ADDR_BUS),
        .C2(C2),
        .C8(C8)
    );
ALU reg_ALU(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_acc_alu_p(ACC_ALU_P),
        .i_acc_alu_q(MBR_ALU_Q),
        .ctrl_alu_op(i_alu_op[2:0]),
        .ctrl_alu_en(i_alu_op[3]),
        .C9(C9),
        .C10(C10),
        .o_mr(MR_ACC),
        .o_br(BR_ACC),
        .o_flags(o_flags),
        .i_user_sample(i_user_sample),
        .o_mr_user(o_MR_user)
    );
IR reg_IR(
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
       .i_mbr_ir(MBR_IR),
       .C4(C4),
       .C14(C14),
       .C15(C15),
       .o_ir_cu(IR_CU),
       .o_ir_mbr(IR_MBR),
       .i_user_sample(i_user_sample),
       .o_ir_user(o_IR_user)
   );

// Assignments to external bus
// Logic are defined in external_bus module
assign o_memory_data = MBR_DATA_BUS;
assign o_memory_addr = MAR_ADDR_BUS;
assign DATA_BUS_MBR = i_memory_data;

// Assignments to CU
assign o_ir_cu = i_ctrl_halt ? 8'b0 : IR_CU;

// Assignments to User interface
// As they are existing for only one clock cycle, the signals should be stored at user interface.

endmodule
