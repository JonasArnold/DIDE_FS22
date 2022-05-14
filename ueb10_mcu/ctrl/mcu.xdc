################################################################
# Project: Hand-made MCU
# Entity : mcu_pkg
# Author : Waj
################################################################

################################################################
# Timing Constraints
################################################################

# Clock signal 
create_clock -add -name sys_clk -period  8.0 [get_ports {clk}]; 

################################################################
# Physical Constraints
################################################################

# Clock signal 
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {clk}];
# Reset signal (uses BTN_0 on ZYBO)
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {rst}];

# GPIO_0 (7 inputs from ZYBO, one already used as reset)
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[0]}]; # SW_0
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[1]}]; # SW_1
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[2]}]; # SW_2
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[3]}]; # SW_3
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[4]}]; # Header JB8 (BTN_0 = rst)
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[5]}]; # BTN_1
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[6]}]; # BTN_2
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {gpio_0[7]}]; # BTN_3

# GPIO_1 (8 outputs to ZYBO
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[0]}]; # LED_0
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[1]}]; # LED_1
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[2]}]; # LED_2
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[3]}]; # LED_3
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[4]}]; # Header JB4 (Buzzer)
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[5]}]; # Header JB3 (LED_R)
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[6]}]; # Header JB10(LED_G)
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {gpio_1[7]}]; # Header JC7 (LED_B)

### FMC outputs for Single-Channel Devices ################################################
# FMC Channel 0 (Pmod JE, upper row)
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {fmc_step[0]}];   # JE2
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {fmc_direct[0]}]; # JE3
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports {fmc_enable[0]}]; # JE4


