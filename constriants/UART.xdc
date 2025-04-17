# UART input
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports i_rx]    

# Clock 100MHz
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports i_clk_uart]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk_uart]
create_clock -period 20.000 -name uart_clk_pin -waveform {0.000 10.000} -add [get_ports i_clk_cpu]

set_clock_groups -name async_group -asynchronous \
  -group [get_clocks sys_clk_pin] \
  -group [get_clocks cpu_clk_pin]
# Buttons   
# BTNU: Reset
# BTND:
# BTNL:
# BTNR:
# BTNC:

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports i_rst_n] 
# set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {key_button[1]}]
# set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {key_button[2]}]
# set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {key_button[3]}]
# set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {key_button[4]}]

# RGB Lights
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports o_instr_transmit_done]

## 7-segment Lights
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[0]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[3]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[5]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[6]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {o_seg_value[7]}]

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[3]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[4]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[5]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {o_seg_valid[7]}]

# Switches

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[1]}]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[2]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[3]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[4]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[5]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[6]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {i_addr_read[7]}]
# set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {key_in_money[0]}]
# set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {key_in_money[1]}]
# set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {key_in_money[2]}]
# set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {key_in_money[3]}]
# # set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {key_in_money[4]}]