module helai_ov5640_rx #(
	parameter BIT_CTRL     = 1'b1 ,
	parameter DEVID        = 8'h78,//8'h78 
	parameter IMAGE_WIDTH  = 1280 ,
	parameter IMAGE_HEIGHT = 720  ,
	parameter RGB_TYPE     = 0	//0-->RGB565  1-->RGB888	
)(
	input         clk_25m     ,
	input         rst_n       ,
	output        cmos_scl    ,
	inout         cmos_sda    ,
	input         cmos_pclk_i ,	//input pixel clock.
	input         cmos_href_i ,	//input pixel hs signal.
	input         cmos_vsync_i,	//input pixel vs signal.
	input  [7:0]  cmos_data_i ,	//data.
	output        cmos_xclk_o ,	//output clock to cmos sensor.
    output        ov5640_hs   ,	
    output        ov5640_vs   ,
    output        ov5640_de   ,
    output [23:0] ov5640_rgb  ,
    output        clk_ce      ,	
	output        cfg_done    ,
    output        cam_rst_n   ,  
    output        cam_pwdn       
);

wire        i2c_exec       ; 
wire [23:0] i2c_data       ;          
wire        i2c_done       ;  //I2C瀵勫瓨鍣ㄩ厤缃畬鎴愪俊鍙?
wire        i2c_dri_clk    ;  //I2C鎿嶄綔鏃堕挓
wire [ 7:0] i2c_data_r     ;  //I2C璇诲嚭鐨勬暟鎹?
wire        i2c_rh_wl      ;  //I2C璇诲啓鎺у埗淇″彿

//涓嶅鎽勫儚澶寸‖浠跺浣?,鍥哄畾楂樼數骞?
assign  cam_rst_n = 1'b1;
//鐢垫簮浼戠湢妯″紡閫夋嫨 0锛氭甯告ā寮? 1锛氱數婧愪紤鐪犳ā寮?
assign  cam_pwdn  = 1'b0;

//I2C閰嶇疆妯″潡
i2c_ov5640_rgb565_cfg i2c_ov5640(
    .clk          (i2c_dri_clk ),
    .rst_n        (rst_n       ),            
    .i2c_exec     (i2c_exec    ),
    .i2c_data     (i2c_data    ),
    .i2c_rh_wl    (i2c_rh_wl   ),      //I2C璇诲啓鎺у埗淇″彿
    .i2c_done     (i2c_done    ), 
    .i2c_data_r   (i2c_data_r  ),                  
    .cmos_h_pixel (IMAGE_WIDTH ),    //CMOS姘村钩鏂瑰悜鍍忕礌涓暟
    .cmos_v_pixel (IMAGE_HEIGHT),    //CMOS鍨傜洿鏂瑰悜鍍忕礌涓暟
    .total_h_pixel(2570        ),    //姘村钩鎬诲儚绱犲ぇ灏?
    .total_v_pixel(980         ),    //鍨傜洿鎬诲儚绱犲ぇ灏?       
    .init_done    (cfg_done    ) 
);    

//I2C椹卞姩妯″潡
i2c_dri #(
    .SLAVE_ADDR(DEVID   ),    //鍙傛暟浼犻??
    .CLK_FREQ  (25000000),              
    .I2C_FREQ  (250000  ) 
)u_i2c_driver(
    .clk                (clk_25m       ),
    .rst_n              (rst_n         ),
    .i2c_exec           (i2c_exec      ),   
    .bit_ctrl           (BIT_CTRL      ),   
    .i2c_rh_wl          (i2c_rh_wl     ),     //鍥哄畾涓?0锛屽彧鐢ㄥ埌浜咺IC椹卞姩鐨勫啓鎿嶄綔   
    .i2c_addr           (i2c_data[23:8]),   
    .i2c_data_w         (i2c_data[7:0] ),   
    .i2c_data_r         (i2c_data_r    ),   
    .i2c_done           (i2c_done      ),    
    .scl                (cmos_scl      ),   
    .sda                (cmos_sda      ),
    .dri_clk            (i2c_dri_clk   )       //I2C鎿嶄綔鏃堕挓
);

ov5640_rx #(
	.RGB_TYPE (RGB_TYPE)	//0-->RGB565  1-->RGB888
)u_ov5640_rx(
    .rstn_i      (cfg_done    ),
	.cmos_clk_i  (clk_25m     ),//cmos senseor clock.
	.cmos_pclk_i (cmos_pclk_i ),//input pixel clock.
	.cmos_href_i (cmos_href_i ),//input pixel hs signal.
	.cmos_vsync_i(cmos_vsync_i),//input pixel vs signal.
	.cmos_data_i (cmos_data_i ),//data.
	.cmos_xclk_o (cmos_xclk_o ),//output clock to cmos sensor.濡傛灉浣犵殑鎽勫儚澶磋嚜甯︽櫠鎸紝鍒欐淇″彿涓嶉渶瑕?
    .rgb_o       (ov5640_rgb  ),
    .de_o        (ov5640_de   ),
    .vs_o        (ov5640_vs   ),
    .hs_o        (ov5640_hs   ),
	.clk_ce      (clk_ce      )
);

endmodule