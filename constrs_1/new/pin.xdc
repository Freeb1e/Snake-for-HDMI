############## clock define##################
create_clock -period 20.000 [get_ports clk]
set_property PACKAGE_PIN N18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

############## key define##################
set_property PACKAGE_PIN P14 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]


set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property PACKAGE_PIN J18 [get_ports uart_rxd]

set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN H18 [get_ports uart_txd]

set_property PACKAGE_PIN U18 [get_ports hdmi_tx_clk_p]
set_property PACKAGE_PIN V20 [get_ports hdmi_tx_chn_b_p]
set_property PACKAGE_PIN T20 [get_ports hdmi_tx_chn_g_p]
set_property PACKAGE_PIN N20 [get_ports hdmi_tx_chn_r_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_chn_r_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_chn_g_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_chn_b_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_clk_p]