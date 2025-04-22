module CLK_DIVIDER (
    i_clk,
    i_rst_n_sync,
    o_clk_div
);
  input i_clk;
  input i_rst_n_sync;
  output reg o_clk_div;

  always @(posedge i_clk) begin
    if (!i_rst_n_sync) begin
      o_clk_div <= 0;
    end else begin
      o_clk_div <= ~o_clk_div;
    end
  end

endmodule
