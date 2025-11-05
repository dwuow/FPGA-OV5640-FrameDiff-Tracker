// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Tue Nov  4 08:26:35 2025
// Host        : LAPTOP-TIS29LGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/SM01_A7_100_ov5640_MF_HDMI_2024/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_ikun_multi_frame_top_0_0/design_1_ikun_multi_frame_top_0_0_stub.v
// Design      : design_1_ikun_multi_frame_top_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ikun_multi_frame_top,Vivado 2020.2" *)
module design_1_ikun_multi_frame_top_0_0(clk, rst_n, Diff_Threshold, target_num_out, 
  s0_axis_tdata, s0_axis_tvalid, s0_axis_tready, s0_axis_tuser, s0_axis_tlast, s1_axis_tdata, 
  s1_axis_tvalid, s1_axis_tready, s1_axis_tuser, s1_axis_tlast, m_axis_tdata, m_axis_tvalid, 
  m_axis_tready, m_axis_tuser, m_axis_tlast)
/* synthesis syn_black_box black_box_pad_pin="clk,rst_n,Diff_Threshold[7:0],target_num_out[3:0],s0_axis_tdata[23:0],s0_axis_tvalid,s0_axis_tready,s0_axis_tuser,s0_axis_tlast,s1_axis_tdata[23:0],s1_axis_tvalid,s1_axis_tready,s1_axis_tuser,s1_axis_tlast,m_axis_tdata[23:0],m_axis_tvalid,m_axis_tready,m_axis_tuser,m_axis_tlast" */;
  input clk;
  input rst_n;
  input [7:0]Diff_Threshold;
  output [3:0]target_num_out;
  input [23:0]s0_axis_tdata;
  input s0_axis_tvalid;
  output s0_axis_tready;
  input s0_axis_tuser;
  input s0_axis_tlast;
  input [23:0]s1_axis_tdata;
  input s1_axis_tvalid;
  output s1_axis_tready;
  input s1_axis_tuser;
  input s1_axis_tlast;
  output [23:0]m_axis_tdata;
  output m_axis_tvalid;
  input m_axis_tready;
  output m_axis_tuser;
  output m_axis_tlast;
endmodule
