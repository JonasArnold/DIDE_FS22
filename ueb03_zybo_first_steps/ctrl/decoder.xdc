################################################################
# Physical Constraints
################################################################

# Inputs
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[0]}]; # SW_0
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[1]}]; # SW_1

# Outputs
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led_po[0]}]; # LED_0
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {led_po[1]}]; # LED_1
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {led_po[2]}]; # LED_2
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {led_po[3]}]; # LED_3
