set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports RXD]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK_100MHz]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports BTNU]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports BTND]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports BTNL]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports BTNR]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports BTNC]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports RGB1_BLUE]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports RGB1_RED]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports RGB2_GREEN]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports RGB2_BLUE]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports RGB2_RED]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[0]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[3]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[5]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[6]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {SEG_VALUE[7]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[3]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[4]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[5]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {SEG_VALID[7]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports START_CPU]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports STEP_EXECUTION]
# UART input

# Clock 100MHz
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK_100MHz]

# set_clock_groups -name async_group -asynchronous #   -group [get_clocks sys_clk_pin] #   -group [get_clocks cpu_clk_pin]


# Buttons


# RGB Lights


# 7-segment Lights



# Switches

# set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[2]}]
# set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[3]}]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[4]}]
# set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[5]}]
# set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[6]}]
# set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[7]}]
# set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {key_in_money[0]}]
# set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {key_in_money[1]}]
# set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {key_in_money[2]}]
# set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {key_in_money[3]}]
# # set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {key_in_money[4]}]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
