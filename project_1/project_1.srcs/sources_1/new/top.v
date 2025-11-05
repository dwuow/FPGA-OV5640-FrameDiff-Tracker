//timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 13:23:51
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
	input         i_clk_50m    ,
	// ov5640                      
	input [7:0]   cmos_data_i  ,
	input         cmos_href_i  ,
	input         cmos_pclk_i  ,
	output        cmos_scl	   ,
	inout         cmos_sda	   ,
	input         cmos_vsync_i ,
	//output        cmos_xclk_o  ,	
	output        cmos_rstn_o  ,
	output        cmos_pwdn_o  ,
	// HDMI out                         
    output        o_hdmi_clk_p ,
    output        o_hdmi_clk_n ,
    output [2: 0] o_hdmi_data_p,
	output [2: 0] o_hdmi_data_n,	
	// DDR3
	output [13:0] DDR3_addr    ,
	output [ 2:0] DDR3_ba      ,
	output        DDR3_cas_n   ,
	output [ 0:0] DDR3_ck_n    ,
	output [ 0:0] DDR3_ck_p    ,
	output [ 0:0] DDR3_cke     ,
    output [0:0]  DDR3_cs_n    ,	
	output [ 3:0] DDR3_dm      ,
	inout  [31:0] DDR3_dq      ,
	inout  [3:0]  DDR3_dqs_n   ,
	inout  [3:0]  DDR3_dqs_p   ,
	output [ 0:0] DDR3_odt     ,
	output        DDR3_ras_n   ,
	output        DDR3_reset_n ,
	output        DDR3_we_n    ,	
	output        ddr3_ok      ,		// led	
	output        led          ,
	output        uart_tx      ,
	output        uart_rx      	
    );
	
wire        clk_25m     ;
wire        clk_hdmi    ; 
wire        clk_hdmix5  ;
wire        rst_n       ;

wire        ui_clk_div ;
wire        ui_div_rstn;

wire        sensor_de   ; 
wire        sensor_hs   ;  
wire        sensor_vs   ;
wire        sensor_ce   ;
wire [23:0] sensor_rgb  ;	
	
wire hdmi_resetn = rst_n;	
wire sensor_clk  = cmos_pclk_i ;	
	
clk_wiz_0 hdmi_clk(
    // Clock out ports
    .clk_sensor(clk_25m   ),     // output clk_sensor
    .clk_hdmi  (clk_hdmi  ),     // output clk_hdmi
    .clk_hdmiX5(clk_hdmix5),     // output clk_hdmiX5
    // Status and control signals
    .locked    (rst_n     ),       // output locked
   // Clock in ports
    .resetn    (ui_div_rstn),
    .clk_in1   (ui_clk_div )
);  	

helai_ov5640_rx #(
	.BIT_CTRL     (1    ),//OV5640的字节地�?�?16�?  0:8�? 1:16�?
	.DEVID        (7'h3c),//8'h78 
	.IMAGE_WIDTH  (1280 ),
	.IMAGE_HEIGHT (720  ),
	.RGB_TYPE     (1'd1	)//0-->RGB565  1-->RGB888	
)u_helai_ov5640_rx(
	.clk_25m     (clk_25m     ),
	.rst_n       (rst_n       ),
	.cmos_scl    (cmos_scl    ),
	.cmos_sda    (cmos_sda    ),
	.cmos_pclk_i (cmos_pclk_i ),	//input pixel clock.
	.cmos_href_i (cmos_href_i ),	//input pixel hs signal.
	.cmos_vsync_i(cmos_vsync_i),	//input pixel vs signal.
	.cmos_data_i (cmos_data_i ),	//data.
	.cam_rst_n   (cmos_rstn_o ),
	.cam_pwdn    (cmos_pwdn_o ),
	//.cmos_xclk_o (cmos_xclk_o ),	//output clock to cmos sensor.如果你的摄像头自带晶振，则此信号不需�?
    .ov5640_rgb  (sensor_rgb  ),
    .ov5640_de   (sensor_de   ),
    .ov5640_vs   (sensor_vs   ),
    .ov5640_hs   (sensor_hs   ),
	.clk_ce      (sensor_ce   ),
	.cfg_done    ()
);
	
design_1 u_design_1(
	.DDR3_addr    (DDR3_addr    ), 
	.DDR3_ba      (DDR3_ba      ),
	.DDR3_cas_n   (DDR3_cas_n   ),
	.DDR3_ck_n    (DDR3_ck_n    ),
	.DDR3_ck_p    (DDR3_ck_p    ),
	.DDR3_cke     (DDR3_cke     ),
	.DDR3_cs_n    (DDR3_cs_n    ),
	.DDR3_dm      (DDR3_dm      ),
	.DDR3_dq      (DDR3_dq      ),
	.DDR3_dqs_n   (DDR3_dqs_n   ),
	.DDR3_dqs_p   (DDR3_dqs_p   ),
	.DDR3_odt     (DDR3_odt     ),
	.DDR3_ras_n   (DDR3_ras_n   ),
	.DDR3_reset_n (DDR3_reset_n ),
	.DDR3_we_n    (DDR3_we_n    ),
	.ddr3_ok      (ddr3_ok      ),
    .clk_in1_0    (i_clk_50m    ),
    .ui_clk_div    (ui_clk_div),
    .ui_div_rstn   (ui_div_rstn),
	.vid_ce       (sensor_ce    ),
	.vid_pclk     (sensor_clk   ),	
	.vid_vs	      (sensor_vs    ),
	.vid_de	      (sensor_de    ),
	.vid_data     (sensor_rgb   ),
	.hdmi_clk	  (clk_hdmi     ),
	.hdmi_clkx5	  (clk_hdmix5   ),
	.hdmi_rstn	  (hdmi_resetn  ),
	.o_hdmi_clk_n (o_hdmi_clk_n ),	
	.o_hdmi_clk_p (o_hdmi_clk_p ),	
	.o_hdmi_data_n(o_hdmi_data_n),	
	.o_hdmi_data_p(o_hdmi_data_p),
    .led_tri_o    (led          ),
    .uart_rxd     (uart_rx      ),
    .uart_txd     (uart_tx      )
);	

endmodule
