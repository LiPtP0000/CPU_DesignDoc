module CLK_DIVIDER #(
    parameter DIVIDE_BY = 2  // 2 or 868
)(
    input  wire i_clk,
    input  wire i_rst_n_sync,
    output reg  o_clk_div
);
    reg rst_n_sync_reg;
    reg [9:0] div_cnt;  


    always @(posedge i_clk or negedge i_rst_n_sync) begin
        if (!i_rst_n_sync)
            rst_n_sync_reg <= 1'b0;
        else
            rst_n_sync_reg <= 1'b1;
    end

  
    always @(posedge i_clk or negedge i_rst_n_sync) begin
        if (!i_rst_n_sync) begin
            div_cnt <= 0;
            o_clk_div <= 1'b1;
        end else if (!rst_n_sync_reg) begin
            div_cnt <= 0;
            o_clk_div <= 1'b1;
        end else begin
            if (div_cnt == DIVIDE_BY/2 - 1) begin
                o_clk_div <= ~o_clk_div;
                div_cnt <= 0;
            end else begin
                div_cnt <= div_cnt + 1'b1;
            end
        end
    end

endmodule
