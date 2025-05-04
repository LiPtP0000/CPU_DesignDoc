module LED_DISPLAY (
           i_clk,
           i_rst_n,
           i_instr_transmit_done,
           i_halt,
           i_step_execution,
           i_start_cpu,
           RGB1_RED,
           RGB1_BLUE,
           RGB2_RED,
           RGB2_BLUE,
           RGB2_GREEN
       );
input i_clk;
input i_rst_n;
input i_instr_transmit_done;
input i_halt;
input i_step_execution;
input i_start_cpu;
output RGB1_RED;
output RGB1_BLUE;
output RGB2_RED;
output RGB2_BLUE;
output RGB2_GREEN;


reg RGB1_RED_reg;
reg RGB1_BLUE_reg;
reg RGB2_RED_reg;
reg RGB2_BLUE_reg;
reg RGB2_GREEN_reg;


reg [1:0] state; 
localparam STATE_IDLE = 2'b00;
localparam STATE_GREEN = 2'b01;
localparam STATE_BLUE  = 2'b10;
localparam STATE_RED   = 2'b11;


always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= STATE_IDLE;
        RGB2_RED_reg <= 1'b0;
        RGB2_BLUE_reg <= 1'b0;
        RGB2_GREEN_reg <= 1'b0; 
    end
    else begin
        case (state)
            STATE_IDLE: begin
                RGB2_GREEN_reg <= 1'b0;
                RGB2_BLUE_reg <= 1'b0;
                RGB2_RED_reg <= 1'b0;
                if (i_instr_transmit_done) begin
                    state <= STATE_GREEN; 
                end
            end
            STATE_GREEN: begin
                RGB2_GREEN_reg <= 1'b1;
                RGB2_BLUE_reg <= 1'b0;
                RGB2_RED_reg <= 1'b0;
                if (i_start_cpu) begin
                    state <= STATE_BLUE; 
                end
            end
            STATE_BLUE: begin
                RGB2_GREEN_reg <= 1'b0;
                RGB2_BLUE_reg <= 1'b1;
                RGB2_RED_reg <= 1'b0;
                if (i_halt) begin
                    state <= STATE_RED; 
                end
            end
            STATE_RED: begin
                RGB2_GREEN_reg <= 1'b0;
                RGB2_BLUE_reg <= 1'b0;
                RGB2_RED_reg <= 1'b1;
            end
            default: begin
                state <= STATE_IDLE; 
            end
        endcase
    end
end
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        RGB1_BLUE_reg <= 1'b0;
        RGB1_RED_reg <= 1'b0;
    end
    else begin
    if (i_step_execution) begin
            RGB1_BLUE_reg <= 1'b0;
            RGB1_RED_reg <= 1'b1;
        end
        else begin
            RGB1_BLUE_reg <= 1'b1;
            RGB1_RED_reg <= 1'b0;
        end
    end
end

// Assignments
assign RGB1_RED = RGB1_RED_reg;
assign RGB1_BLUE = RGB1_BLUE_reg;
assign RGB2_RED = RGB2_RED_reg;
assign RGB2_BLUE = RGB2_BLUE_reg;
assign RGB2_GREEN = RGB2_GREEN_reg;

endmodule
