################################################################
# Project: ECS Uebung 10
# Entity : pwm_led_top.vhd
# Author : Waj
################################################################

################################################################
# Physical Constraints
################################################################

# Clock & Reset
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports clk_pi]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports rst_pi]

# Inputs
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {act_pi[2]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {act_pi[1]}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {act_pi[0]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports {enc_pi[1]}]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports {enc_pi[0]}]
set_property PULLUP true [get_ports {enc_pi[1]}]
set_property PULLUP true [get_ports {enc_pi[0]}]
# Outputs
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports {led_po[2]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {led_po[1]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {led_po[0]}]

################################################################
# Timing Constraints
################################################################

# Clock signal
create_clock -period 8.000 -name sys_clk -waveform {0.000 4.000} -add [get_ports clk_pi]

