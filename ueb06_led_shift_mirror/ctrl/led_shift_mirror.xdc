################################################################
# Project: ECS Uebung 6
# Entity : led_rotate.vhd
# Author : Waj
################################################################

################################################################
# Physical Constraints
################################################################

# Clock & Reset
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports clk_pi]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports rst_pi]

# Inputs
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports enca_pi]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports encb_pi]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports mirr_pi]
set_property PULLUP TRUE [get_ports { enca_pi }];
set_property PULLUP TRUE [get_ports { encb_pi }];
set_property PULLUP TRUE [get_ports { mirr_pi }];

# Outputs
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led_po[0]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {led_po[1]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {led_po[2]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {led_po[3]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {led_po[4]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led_po[5]}]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {led_po[6]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led_po[7]}]

################################################################
# Timing Constraints
################################################################

# Clock signal
create_clock -period 8.000 -name sys_clk -waveform {0.000 4.000} -add [get_ports clk_pi]



