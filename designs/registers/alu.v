/*
module ALU
Author: LiPtP
function:
1. update BR and MR registers on rising clock edge when `ctrl_alu_en` is open;
2. Bus control using C9, C10, the target port is o_br and o_mr;
3. Operation encoding is defined in doc.
*/
module ALU (
           i_clk,
           i_rst_n,
           i_acc_alu_p,
           i_acc_alu_q,
           ctrl_alu_op,
           ctrl_alu_en,
           C9,
           C10,
           o_mr,
           o_br,
           o_flags
       );
input i_clk;
input i_rst_n;
input [15:0] i_acc_alu_p;
input [15:0] i_acc_alu_q;
input [2:0] ctrl_alu_op;
input ctrl_alu_en;
input C9;
input C10;
output [15:0] o_mr;
output [15:0] o_br;
output [4:0] o_flags;

// Re-interpret input to signed values
wire signed [15:0] ALU_P = i_acc_alu_p;
wire signed [15:0] ALU_Q = i_acc_alu_q;

// Calculation result
reg signed [15:0] ALU_RES_LOW;
reg signed [15:0] ALU_RES_HIGH;

// Output registers
reg [15:0] BR;
reg [15:0] MR;

// Flags
reg ZF, CF, OF, NF, MF;

// Combinational logic: ALU Operation
always @(*) begin
    // Default
    ALU_RES_LOW = 16'b0;
    ALU_RES_HIGH = 16'b0;
    
    case (ctrl_alu_op)
        3'b000: begin // ADD
            ALU_RES_LOW = ALU_P + ALU_Q;
        end
        3'b001: begin // SUB
            ALU_RES_LOW = ALU_P - ALU_Q;
        end
        3'b010: begin // MPY
            {ALU_RES_HIGH, ALU_RES_LOW} = ALU_P * ALU_Q;
        end
        3'b011: begin // AND
            ALU_RES_LOW = ALU_P & ALU_Q;
        end
        3'b100: begin // OR
            ALU_RES_LOW = ALU_P | ALU_Q;
        end
        3'b101: begin // NOT
            ALU_RES_LOW = ~ALU_P;
        end
        3'b110: begin // SHIFTL
            ALU_RES_LOW = ALU_P <<< 1;
        end
        3'b111: begin // SHIFTR
            ALU_RES_LOW = ALU_P >>> 1;
        end
        default: begin
            ALU_RES_LOW = 16'b0;
            ALU_RES_HIGH = 16'b0;
        end
    endcase
end

// Sequential logic: Update BR and MR upon ctrl_alu_en
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        BR <= 16'b0;
        MR <= 16'b0;
    end else if (ctrl_alu_en) begin
        BR <= ALU_RES_LOW;
        MR <= ALU_RES_HIGH;
    end else begin
        BR <= BR;
        MR <= MR;
    end
end

// Sequential logic: Update Flags upon ctrl_alu_en
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        ZF <= 1'b0;
        CF <= 1'b0;
        OF <= 1'b0;
        NF <= 1'b0;
        MF <= 1'b0;
    end else if (ctrl_alu_en) begin
        ZF <= (ctrl_alu_op == 3'b010) ? ({ALU_RES_HIGH, ALU_RES_LOW} == 32'b0) : (ALU_RES_LOW == 16'b0);
        CF <= (ctrl_alu_op == 3'b110) ? ALU_P[15] :        // SHIFTL highest bit
              (ctrl_alu_op == 3'b111) ? ALU_P[0]  : 1'b0;   // SHIFTR lowest bit
        OF <= (ctrl_alu_op == 3'b000) ? ((ALU_P[15] == ALU_Q[15]) && (ALU_RES_LOW[15] != ALU_P[15])) : // ADD overflow
              (ctrl_alu_op == 3'b001) ? ((ALU_P[15] != ALU_Q[15]) && (ALU_RES_LOW[15] != ALU_P[15])) : // SUB overflow
              (ctrl_alu_op == 3'b010) ? (ALU_RES_HIGH != 16'b0) : 1'b0; // MPY overflow
        NF <= ALU_RES_LOW[15];
        MF <= (ctrl_alu_op == 3'b010); // only MPY sets MF
    end else begin
        ZF <= ZF;
        CF <= CF;
        OF <= OF;
        NF <= NF;
        MF <= MF;
    end
end

// Output
assign o_br = C9 ? BR : 16'b0;
assign o_mr = C10 ? MR : 16'b0;
assign o_flags = {ZF, CF, OF, NF, MF};

endmodule
