//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Tue Nov  4 08:25:06 2025
//Host        : LAPTOP-TIS29LGK running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR3_addr,
    DDR3_ba,
    DDR3_cas_n,
    DDR3_ck_n,
    DDR3_ck_p,
    DDR3_cke,
    DDR3_cs_n,
    DDR3_dm,
    DDR3_dq,
    DDR3_dqs_n,
    DDR3_dqs_p,
    DDR3_odt,
    DDR3_ras_n,
    DDR3_reset_n,
    DDR3_we_n,
    clk_in1_0,
    ddr3_ok,
    hdmi_clk,
    hdmi_clkx5,
    hdmi_rstn,
    led_tri_o,
    o_hdmi_clk_n,
    o_hdmi_clk_p,
    o_hdmi_data_n,
    o_hdmi_data_p,
    uart_rxd,
    uart_txd,
    ui_clk_div,
    ui_div_rstn,
    vid_ce,
    vid_data,
    vid_de,
    vid_pclk,
    vid_vs);
  output [13:0]DDR3_addr;
  output [2:0]DDR3_ba;
  output DDR3_cas_n;
  output [0:0]DDR3_ck_n;
  output [0:0]DDR3_ck_p;
  output [0:0]DDR3_cke;
  output [0:0]DDR3_cs_n;
  output [3:0]DDR3_dm;
  inout [31:0]DDR3_dq;
  inout [3:0]DDR3_dqs_n;
  inout [3:0]DDR3_dqs_p;
  output [0:0]DDR3_odt;
  output DDR3_ras_n;
  output DDR3_reset_n;
  output DDR3_we_n;
  input clk_in1_0;
  output ddr3_ok;
  input hdmi_clk;
  input hdmi_clkx5;
  input hdmi_rstn;
  output [0:0]led_tri_o;
  output o_hdmi_clk_n;
  output o_hdmi_clk_p;
  output [2:0]o_hdmi_data_n;
  output [2:0]o_hdmi_data_p;
  input uart_rxd;
  output uart_txd;
  output ui_clk_div;
  output [0:0]ui_div_rstn;
  input vid_ce;
  input [23:0]vid_data;
  input vid_de;
  input vid_pclk;
  input vid_vs;

  wire [13:0]DDR3_addr;
  wire [2:0]DDR3_ba;
  wire DDR3_cas_n;
  wire [0:0]DDR3_ck_n;
  wire [0:0]DDR3_ck_p;
  wire [0:0]DDR3_cke;
  wire [0:0]DDR3_cs_n;
  wire [3:0]DDR3_dm;
  wire [31:0]DDR3_dq;
  wire [3:0]DDR3_dqs_n;
  wire [3:0]DDR3_dqs_p;
  wire [0:0]DDR3_odt;
  wire DDR3_ras_n;
  wire DDR3_reset_n;
  wire DDR3_we_n;
  wire clk_in1_0;
  wire ddr3_ok;
  wire hdmi_clk;
  wire hdmi_clkx5;
  wire hdmi_rstn;
  wire [0:0]led_tri_o;
  wire o_hdmi_clk_n;
  wire o_hdmi_clk_p;
  wire [2:0]o_hdmi_data_n;
  wire [2:0]o_hdmi_data_p;
  wire uart_rxd;
  wire uart_txd;
  wire ui_clk_div;
  wire [0:0]ui_div_rstn;
  wire vid_ce;
  wire [23:0]vid_data;
  wire vid_de;
  wire vid_pclk;
  wire vid_vs;

  design_1 design_1_i
       (.DDR3_addr(DDR3_addr),
        .DDR3_ba(DDR3_ba),
        .DDR3_cas_n(DDR3_cas_n),
        .DDR3_ck_n(DDR3_ck_n),
        .DDR3_ck_p(DDR3_ck_p),
        .DDR3_cke(DDR3_cke),
        .DDR3_cs_n(DDR3_cs_n),
        .DDR3_dm(DDR3_dm),
        .DDR3_dq(DDR3_dq),
        .DDR3_dqs_n(DDR3_dqs_n),
        .DDR3_dqs_p(DDR3_dqs_p),
        .DDR3_odt(DDR3_odt),
        .DDR3_ras_n(DDR3_ras_n),
        .DDR3_reset_n(DDR3_reset_n),
        .DDR3_we_n(DDR3_we_n),
        .clk_in1_0(clk_in1_0),
        .ddr3_ok(ddr3_ok),
        .hdmi_clk(hdmi_clk),
        .hdmi_clkx5(hdmi_clkx5),
        .hdmi_rstn(hdmi_rstn),
        .led_tri_o(led_tri_o),
        .o_hdmi_clk_n(o_hdmi_clk_n),
        .o_hdmi_clk_p(o_hdmi_clk_p),
        .o_hdmi_data_n(o_hdmi_data_n),
        .o_hdmi_data_p(o_hdmi_data_p),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd),
        .ui_clk_div(ui_clk_div),
        .ui_div_rstn(ui_div_rstn),
        .vid_ce(vid_ce),
        .vid_data(vid_data),
        .vid_de(vid_de),
        .vid_pclk(vid_pclk),
        .vid_vs(vid_vs));
endmodule
