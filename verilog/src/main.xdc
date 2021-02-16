set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK100]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK100]

set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports RESET]

set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports TXD]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports RXD]

set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports LED[0]]
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports LED[1]]
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports LED[2]]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports LED[3]]

