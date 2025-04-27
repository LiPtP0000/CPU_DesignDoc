
module EXTERNAL_BUS (
           i_clk,
           i_rst_n,
           i_mbr_data_bus,
           i_mar_address_bus,
           i_instr,
           i_data,
           o_data_bus_mbr,
           o_data_bus_memory,
           o_address_bus_memory,
           o_instr_rom_read,
           o_data_ram_read,
           o_data_ram_write,
           C0,
           C2,
           C5,
           C13
       );
       
input i_clk;
input i_rst_n;

input C0;
input C2;
input C5;
input C13;

// reg <-> bus

input [15:0] i_mbr_data_bus;
input [7:0] i_mar_address_bus;
output [15:0] o_data_bus_mbr;

// memory <-> bus

input [15:0] i_instr; // Instruction
input [15:0] i_data; // Data to be written to RAM
output o_instr_rom_read;    
output o_data_ram_read;     
output o_data_ram_write;     
output [15:0] o_data_bus_memory;
output [7:0] o_address_bus_memory;

wire memory_read_en = C0 & C5; // Memory read enable, 
wire memory_write_en = C0 & C13; // Memory write enable

wire [15:0] DATA_BUS;
wire [7:0] ADDRESS_BUS;

reg memory_select;

// Memory Select logic on t1
always @(posedge i_clk or i_rst_n) begin
    if(!i_rst_n) begin
        memory_select <= 1'b0; // Default to RAM
    end
    else begin
        if(C2) begin
            memory_select <= 1'b1; // ROM
        end
        else begin
            memory_select <= 1'b0; // RAM
        end
    end
end

// Address Bus
always @(*) begin
    if(memory_write_en) begin
        ADDRESS_BUS = i_mar_address_bus;
    end
    else begin
        ADDRESS_BUS = 8'b0;
    end
end

// Data Bus
always @(*) begin
    if(memory_read_en) begin
        DATA_BUS = memory_select ? i_instr : i_data;
    end
    else if (memory_write_en) begin
        DATA_BUS = i_mbr_data_bus;
    end
    else begin
        DATA_BUS = 16'b0;
    end
end

// Control Bus

assign o_instr_rom_read = memory_select & memory_read_en;
assign o_data_ram_read = ~memory_select & memory_read_en;
assign o_data_ram_write = ~memory_select & memory_write_en;

// Data Connections

assign o_data_bus_mbr = memory_read_en ? DATA_BUS : 16'b0;
assign o_data_bus_memory = memory_write_en ? DATA_BUS : 16'b0;
assign o_address_bus_memory = memory_write_en ? ADDRESS_BUS : 8'b0;
endmodule
