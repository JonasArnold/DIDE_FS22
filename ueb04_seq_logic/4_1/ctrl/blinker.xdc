################################################################
# Project: ECS Uebung 4.1
# Entity : blinker.vhd
# Author : Waj
################################################################

################################################################
# Physical Constraints
################################################################

# Clock & Reset
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {clk_pi}]; # CLK
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {rst_pi}]; # BTN_0 = RST

# Inputs

# Outputs
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led_po[0]}]; # LED_0
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {led_po[1]}]; # LED_1
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {led_po[2]}]; # LED_2
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {led_po[3]}]; # LED_3

################################################################
# Timing Constraints
################################################################

# Clock signal 
create_clock -add -name sys_clk -period 8.0 -waveform {0 4.0} [get_ports {clk_pi}]; 



