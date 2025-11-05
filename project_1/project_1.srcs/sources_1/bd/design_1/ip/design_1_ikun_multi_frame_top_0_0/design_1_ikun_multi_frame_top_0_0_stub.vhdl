-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Tue Nov  4 08:26:35 2025
-- Host        : LAPTOP-TIS29LGK running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/SM01_A7_100_ov5640_MF_HDMI_2024/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_ikun_multi_frame_top_0_0/design_1_ikun_multi_frame_top_0_0_stub.vhdl
-- Design      : design_1_ikun_multi_frame_top_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_ikun_multi_frame_top_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    Diff_Threshold : in STD_LOGIC_VECTOR ( 7 downto 0 );
    target_num_out : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s0_axis_tdata : in STD_LOGIC_VECTOR ( 23 downto 0 );
    s0_axis_tvalid : in STD_LOGIC;
    s0_axis_tready : out STD_LOGIC;
    s0_axis_tuser : in STD_LOGIC;
    s0_axis_tlast : in STD_LOGIC;
    s1_axis_tdata : in STD_LOGIC_VECTOR ( 23 downto 0 );
    s1_axis_tvalid : in STD_LOGIC;
    s1_axis_tready : out STD_LOGIC;
    s1_axis_tuser : in STD_LOGIC;
    s1_axis_tlast : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 23 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tuser : out STD_LOGIC;
    m_axis_tlast : out STD_LOGIC
  );

end design_1_ikun_multi_frame_top_0_0;

architecture stub of design_1_ikun_multi_frame_top_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rst_n,Diff_Threshold[7:0],target_num_out[3:0],s0_axis_tdata[23:0],s0_axis_tvalid,s0_axis_tready,s0_axis_tuser,s0_axis_tlast,s1_axis_tdata[23:0],s1_axis_tvalid,s1_axis_tready,s1_axis_tuser,s1_axis_tlast,m_axis_tdata[23:0],m_axis_tvalid,m_axis_tready,m_axis_tuser,m_axis_tlast";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ikun_multi_frame_top,Vivado 2020.2";
begin
end;
