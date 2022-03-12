################################################################
# Physical Constraints
################################################################

# Inputs (on ZYBO board)
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[0]}]; # SW_0
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[1]}]; # SW_1
#set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[2]}]; # SW_2
#set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports {sw_pi[3]}]; # SW_3
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {btn_pi[0]}]; # BTN_0
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports {btn_pi[1]}]; # BTN_1
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {btn_pi[2]}]; # BTN_2
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {btn_pi[3]}]; # BTN_3

# Outputs (on I/O Extension board)
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led_po[0] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { led_po[1] }];
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { led_po[2] }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { led_po[3] }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { led_po[4] }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led_po[5] }];
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { led_po[6] }];
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led_po[7] }];