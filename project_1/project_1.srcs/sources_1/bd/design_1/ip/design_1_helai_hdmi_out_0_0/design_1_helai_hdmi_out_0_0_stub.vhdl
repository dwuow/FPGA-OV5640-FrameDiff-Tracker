-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Mon Nov  3 22:40:53 2025
-- Host        : LAPTOP-TIS29LGK running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/SM01_A7_100_ov5640_MF_HDMI_2024/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_helai_hdmi_out_0_0/design_1_helai_hdmi_out_0_0_stub.vhdl
-- Design      : design_1_helai_hdmi_out_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_helai_hdmi_out_0_0 is
  Port ( 
    clk_hdmi : in STD_LOGIC;
    clk_hdmix5 : in STD_LOGIC;
    reset_n : in STD_LOGIC;
    i_vga_hs : in STD_LOGIC;
    i_vga_vs : in STD_LOGIC;
    i_vga_de : in STD_LOGIC;
    i_vga_rgb : in STD_LOGIC_VECTOR ( 23 downto 0 );
    o_hdmi_clk_p : out STD_LOGIC;
    o_hdmi_clk_n : out STD_LOGIC;
    o_hdmi_data_p : out STD_LOGIC_VECTOR ( 2 downto 0 );
    o_hdmi_data_n : out STD_LOGIC_VECTOR ( 2 downto 0 )
  );

end design_1_helai_hdmi_out_0_0;

architecture stub of design_1_helai_hdmi_out_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_hdmi,clk_hdmix5,reset_n,i_vga_hs,i_vga_vs,i_vga_de,i_vga_rgb[23:0],o_hdmi_clk_p,o_hdmi_clk_n,o_hdmi_data_p[2:0],o_hdmi_data_n[2:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "helai_hdmi_out,Vivado 2020.2";
begin
end;
