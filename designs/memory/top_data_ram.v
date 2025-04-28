/*
module DATA_RAM
Author: LiPtP
function:
0. Write means write to RAM, READ means read from RAM
1. Write data to itself according to input address and data
2. Output data according to input address
*/
module DATA_RAM (
           i_clk,
           i_rst_n,
           ctrl_write,
           i_addr_write,
           i_data_write,
           ctrl_read,
           i_addr_read,
           o_data_read
       );
input           i_clk;
input           i_rst_n;
input           ctrl_write;
input   [7:0]   i_addr_write;
input   [15:0]  i_data_write;
input           ctrl_read;
input   [7:0]   i_addr_read;
output   [15:0] o_data_read;

// 256 x 16 RAM storage
reg [15:0] mem [0:255];

// Write Operation, no initialization of data RAM
always @(posedge i_clk) begin
    if (ctrl_write) begin
        mem[i_addr_write] <= i_data_write;
    end
end

// Read Operation
assign o_data_read = ctrl_read ? mem[i_addr_read] : 16'b0;

endmodule
