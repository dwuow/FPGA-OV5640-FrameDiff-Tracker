// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Mon Nov  3 22:40:53 2025
// Host        : LAPTOP-TIS29LGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/SM01_A7_100_ov5640_MF_HDMI_2024/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_helai_hdmi_out_0_0/design_1_helai_hdmi_out_0_0_stub.v
// Design      : design_1_helai_hdmi_out_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "helai_hdmi_out,Vivado 2020.2" *)
module design_1_helai_hdmi_out_0_0(clk_hdmi, clk_hdmix5, reset_n, i_vga_hs, 
  i_vga_vs, i_vga_de, i_vga_rgb, o_hdmi_clk_p, o_hdmi_clk_n, o_hdmi_data_p, o_hdmi_data_n)
/* synthesis syn_black_box black_box_pad_pin="clk_hdmi,clk_hdmix5,reset_n,i_vga_hs,i_vga_vs,i_vga_de,i_vga_rgb[23:0],o_hdmi_clk_p,o_hdmi_clk_n,o_hdmi_data_p[2:0],o_hdmi_data_n[2:0]" */;
  input clk_hdmi;
  input clk_hdmix5;
  input reset_n;
  input i_vga_hs;
  input i_vga_vs;
  input i_vga_de;
  input [23:0]i_vga_rgb;
  output o_hdmi_clk_p;
  output o_hdmi_clk_n;
  output [2:0]o_hdmi_data_p;
  output [2:0]o_hdmi_data_n;
endmodule
