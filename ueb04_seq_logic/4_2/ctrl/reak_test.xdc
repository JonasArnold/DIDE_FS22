################################################################
# Project: ECS Uebung 4.2
# Entity : reak_test.vhd
# Author : Waj
################################################################

################################################################
# Physical Constraints
################################################################

# Clock & Reset
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {clk_pi}]; # CLK
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {rst_pi}]; # BTN_0 = RST

# Inputs
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {stop_pi}]; # BTN_3 = stop

# Outputs (on I/O Extension board)
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led_po[0] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { led_po[1] }];
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { led_po[2] }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { led_po[3] }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { led_po[4] }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led_po[5] }];
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { led_po[6] }];
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led_po[7] }];

################################################################
# Timing Constraints
################################################################

# Clock signal 
create_clock -add -name sys_clk -period 8.0 -waveform {0 4.0} [get_ports {clk_pi}]; 



