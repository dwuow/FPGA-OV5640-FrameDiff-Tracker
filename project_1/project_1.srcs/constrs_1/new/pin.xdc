#--------------------------------system clk------------------------------------------------------
set_property PACKAGE_PIN R4 [get_ports i_clk_50m]
set_property IOSTANDARD LVCMOS15 [get_ports i_clk_50m]               
create_clock -period 20.000 -name sys_clk_50m [get_ports i_clk_50m]
set_clock_groups -asynchronous -group [get_clocks sys_clk_50m -include_generated_clocks]

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets u_design_1/clk_wiz_1/inst/clk_in1_design_1_clk_wiz_1_0]

set_property PACKAGE_PIN Y8 [get_ports ddr3_ok]
set_property IOSTANDARD LVCMOS15 [get_ports ddr3_ok]

set_property PACKAGE_PIN V9 [get_ports led]
set_property IOSTANDARD LVCMOS15 [get_ports led]

set_property PACKAGE_PIN D17 [get_ports uart_tx]
set_property PACKAGE_PIN E14 [get_ports uart_rx]

set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

#---------------------------ov5640_1---------------------------
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cmos_pclk_i_IBUF]
set_property PACKAGE_PIN N13  [get_ports cmos_scl]
set_property PACKAGE_PIN R14  [get_ports cmos_sda]
set_property PACKAGE_PIN P14 [get_ports cmos_vsync_i]
set_property PACKAGE_PIN N14 [get_ports cmos_href_i]
set_property PACKAGE_PIN U18 [get_ports cmos_pclk_i]
set_property PACKAGE_PIN N17  [get_ports cmos_rstn_o]
set_property PACKAGE_PIN AB18  [get_ports cmos_pwdn_o]
set_property PACKAGE_PIN U17 [get_ports {cmos_data_i[7]}]
set_property PACKAGE_PIN W17 [get_ports {cmos_data_i[6]}]
set_property PACKAGE_PIN V17  [get_ports {cmos_data_i[5]}]
set_property PACKAGE_PIN P16  [get_ports {cmos_data_i[4]}]
set_property PACKAGE_PIN R17  [get_ports {cmos_data_i[3]}]
set_property PACKAGE_PIN R16  [get_ports {cmos_data_i[2]}]
set_property PACKAGE_PIN P15  [get_ports {cmos_data_i[1]}]
set_property PACKAGE_PIN P17  [get_ports {cmos_data_i[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports cmos_vsync_i]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_href_i]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_pclk_i]
set_property IOSTANDARD LVCMOS33 [get_ports {cmos_data_i[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_scl]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_sda]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_rstn_o]
set_property IOSTANDARD LVCMOS33 [get_ports cmos_pwdn_o]
set_property PULLUP true [get_ports cmos_scl]
set_property PULLUP true [get_ports cmos_sda]

#-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------
#--------------------------HDMI1 OUT--------------------------------------------------------------
set_property PACKAGE_PIN J20 [get_ports o_hdmi_clk_p]
set_property PACKAGE_PIN J22 [get_ports {o_hdmi_data_p[0]}]
set_property PACKAGE_PIN K21 [get_ports {o_hdmi_data_p[1]}]
set_property PACKAGE_PIN H20 [get_ports {o_hdmi_data_p[2]}]

set_property IOSTANDARD TMDS_33 [get_ports o_hdmi_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports {o_hdmi_data_p[*]}]

#bit compress spix4 speed up
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]