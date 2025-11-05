//AXI ST VIP接口的帧差法

module ikun_multi_frame #(
	parameter IMG_HDISP 	 = 1280,	//图像分辨率
	parameter IMG_VDISP 	 = 720  	//

)(
    input 				clk				,
    input 				rst_n			,
	input  [ 7:0] 		Diff_Threshold  ,	//帧差阈值,默认75
	output [ 3:0]       target_num_out  ,   //最终目标数目
    
    //AXI_ST Slave 接口0，来自摄像头 
    input [23:0] 		s0_axis_tdata   ,
    input        		s0_axis_tvalid  ,
    output       		s0_axis_tready  ,
    input        		s0_axis_tuser   ,
    input        		s0_axis_tlast   ,
    
    //AXI_ST Slave 接口1，来自VDMA 
    input [23:0] 		s1_axis_tdata   ,
    input        		s1_axis_tvalid  ,
    output       		s1_axis_tready  ,
    input        		s1_axis_tuser   ,
    input        		s1_axis_tlast   ,
	
	//AXI_ST Master 接口，输出给VDMA 
    output     [23:0] 	m_axis_tdata	,
    output            	m_axis_tvalid	,
    input             	m_axis_tready	,
    output            	m_axis_tuser	,
    output            	m_axis_tlast 
    );

localparam  DW              = 24;
localparam  AW              = 11;
localparam  M               = 3;
localparam  N               = 3;

localparam  PIPE_STEP       =  2;
localparam  FIFO_PIPE_DEPTH = 16;


//---------------------------------------------
wire                        fifo_pipe_full          ;
wire                        fifo_pipe_almost_full   ;
wire                        fifo_pipe_empty         ;
wire    [4:0]               fifo_pipe_data_count    ;
wire                        fifo_pipe_ready;

assign  fifo_pipe_ready =   ((fifo_pipe_full==1'b0)&&(fifo_pipe_data_count < FIFO_PIPE_DEPTH - PIPE_STEP)) ? 1'b1 : 1'b0;



//*****************************************************
//将VDMA的图像缓存到FIFO中

reg   [23:0]	fifo_data;
reg           	fifo_wr	 ;
reg 			fifo_wr_en;	
wire          	fifo_almost_full;
    
wire          	fifo_rd   ;
reg          	fifo_rd_en;
wire [23:0]   	fifo_q    ;
reg          	fifo_valid;
wire          	fifo_empty;

//FIFO不满时，持续从VDMA读取数据
assign s1_axis_tready = ~fifo_almost_full;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		fifo_wr_en	<= 1'b0;
        fifo_wr 	<= 1'b0;
		fifo_data	<= 24'd0;
	end
    else begin
		//检测到SOF后才打开写FIFO使能，保证FIFO中写入的第一个数据为SOF
		if(s1_axis_tvalid & s1_axis_tready & s1_axis_tuser) 
			fifo_wr_en	<= 1'b1;
	
		if(s1_axis_tvalid & s1_axis_tready) begin
			fifo_wr 	<= 1'b1;
			fifo_data	<= s1_axis_tdata; 
		end  
		else  begin
			fifo_wr 	<= 1'b0;
			fifo_data	<= fifo_data;
		end
	end
end

//缓存来自VDMA的AXI ST 视频, FWFT模式
video_fifo u_video_fifo (
  .clk                      (clk),         
  .srst                     (~rst_n),      
                
  .din                      (fifo_data),
  .wr_en                    (fifo_wr & fifo_wr_en),  
  .full                     (),
                
  .rd_en                    (fifo_rd & fifo_rd_en),  
  .dout                     (fifo_q),   
  .empty                    (fifo_empty),
  
  .almost_full              (fifo_almost_full),
  .almost_empty             () 
);

//*****************************************************消耗一个时钟周期
//寄存来自摄像头的视频
reg     [DW-1: 0]       video_in_data               ;
reg                     video_in_valid              ; 
wire                    video_in_ready              ;
reg                     video_in_last               ;
reg                     video_in_user               ;
wire                    video_in_sof                ;

wire                    frame_diff_ready            ;

assign  video_in_sof    =   s0_axis_tvalid & s0_axis_tready & s0_axis_tuser;
assign  video_in_ready  =   fifo_pipe_ready && frame_diff_ready;

//输出给摄像头输入的Ready信号
assign  s0_axis_tready  =   video_in_ready;

//------------------------------------ step 1

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_data   <= {DW{1'b0}};
    end
    else if( s0_axis_tready && s0_axis_tvalid) begin
        video_in_data   <= s0_axis_tdata;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_valid  <= 1'b0;
        video_in_last   <= 1'b0;
        video_in_user   <= 1'b0;
    end
    else if( s0_axis_tready ) begin
        video_in_valid  <= s0_axis_tvalid;
        video_in_last   <= s0_axis_tvalid & s0_axis_tlast;
        video_in_user   <= s0_axis_tvalid & s0_axis_tuser;
    end
end

//*****************************************************
//摄像头输入像素的同时，从FIFO中读出VDMA像素，以进行帧差运算
assign  fifo_rd =   video_in_valid && video_in_ready;

//------------------------------------ step 1
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		fifo_rd_en	<= 1'b0;
	end
    else begin
		//等待FIFO中缓存一定量的数据之后，检测摄像头输入SOF后才打开读FIFO使能，使得与FIFO中读取的VMDA视频同步
		if(video_in_sof & fifo_almost_full) 
			fifo_rd_en	<= 1'b1;
	end
end

//*****************************************************消耗一个时钟周期
//获取两路RGB格式数据

reg     [DW-1: 0]       video_rgb_data0             ;   //摄像头数据
reg     [DW-1: 0]       video_rgb_data1             ;   //VDMA数据
reg                     video_rgb_valid             ; 
reg                     video_rgb_last              ;
reg                     video_rgb_user              ;

//------------------------------------ step 2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_rgb_data0 <= {DW{1'b0}};
        video_rgb_data1 <= {DW{1'b0}};
    end
    else if(video_in_valid && video_in_ready) begin
        video_rgb_data0 <= video_in_data;
        video_rgb_data1 <= fifo_q       ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_rgb_valid  <= 1'b0;
        video_rgb_last   <= 1'b0;
        video_rgb_user   <= 1'b0;
    end
    else if( video_in_ready ) begin
        video_rgb_valid  <= video_in_valid;
        video_rgb_last   <= video_in_valid && video_in_last;
        video_rgb_user   <= video_in_valid && video_in_user;
    end
end

//*****************************************************消耗两个时钟周期
//将RGB格式的像素数据转成灰度图像
//  Y   =  R*0.299 + G*0.587 + B*0.114
//  Y   = (76 *R + 150*G + 29 *B)>>8

wire   [7:0]   img0_red   ;  //来自摄像头
wire   [7:0]   img0_green ;
wire   [7:0]   img0_blue  ;  

wire   [7:0]   img1_red   ;  //来自VDMA
wire   [7:0]   img1_green ;
wire   [7:0]   img1_blue  ;  

assign img0_red    = video_rgb_data0[23:16]  ;  //来自摄像头
assign img0_green  = video_rgb_data0[15: 8]  ;
assign img0_blue   = video_rgb_data0[ 7: 0]  ;  

assign img1_red    = video_rgb_data1[23:16]  ;  //来自VDMA
assign img1_green  = video_rgb_data1[15: 8]  ;
assign img1_blue   = video_rgb_data1[ 7: 0]  ;  

//------------------------------------ step 3
reg [15:0]  img_red_mult0   ;
reg [15:0]  img_red_mult1   ;

reg [15:0]  img_green_mult0 ;
reg [15:0]  img_green_mult1 ;

reg [15:0]  img_blue_mult0  ;
reg [15:0]  img_blue_mult1  ;

// multiply coefficient
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_red_mult0   <= 16'd0;
        img_red_mult1   <= 16'd0; 

        img_green_mult0 <= 16'd0;
        img_green_mult1 <= 16'd0;

        img_blue_mult0  <= 16'd0;
        img_blue_mult1  <= 16'd0;
    end
    else if( video_in_ready ) begin
        img_red_mult0   <= img0_red   * 8'd76  ;
        img_red_mult1   <= img1_red   * 8'd76  ;  
        
        img_green_mult0 <= img0_green * 8'd150 ;
        img_green_mult1 <= img1_green * 8'd150 ;
        
        img_blue_mult0  <= img0_blue  * 8'd29  ;
        img_blue_mult1  <= img1_blue  * 8'd29  ;
    end
end

//---------------------------------------------step 4
reg [15:0]  img_y_r0 ;   
reg [15:0]  img_y_r1 ;   

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_y_r0    <= 16'd0;
        img_y_r1    <= 16'd0;
    end
    else if( video_in_ready ) begin
        img_y_r0    <= img_red_mult0  + img_green_mult0 + img_blue_mult0;
        img_y_r1    <= img_red_mult1  + img_green_mult1 + img_blue_mult1;
    end
end

wire [7:0]	s0_img_y;   //摄像头图像灰度
wire [7:0]	s1_img_y;	//VDMA图像灰度

assign  s0_img_y = img_y_r0[15:8] ;	
assign  s1_img_y = img_y_r1[15:8] ;	

//作者：大磊
//QQ  : 3183701261
//B站 ：大磊FPGA

//*****************************************************消耗一个时钟周期 
//帧差运算

//帧差标志位，为1表示两帧数据差别超过阈值 
reg frame_diff_flag;	

//---------------------------------------------step 5
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		frame_diff_flag	<= 1'b0;
	end
    else if( video_in_ready )  begin
		if(s0_img_y > s1_img_y) begin
			if(s0_img_y - s1_img_y > Diff_Threshold)	//灰度差大于阈值
				frame_diff_flag <= 1'b1; 
			else
				frame_diff_flag <= 1'b0;	 
		end
		else begin
			if(s1_img_y - s0_img_y > Diff_Threshold)	//灰度差大于阈值
				frame_diff_flag <= 1'b1; 
			else
				frame_diff_flag <= 1'b0;
		end
	end
end

//*****************************************************延迟三个时钟周期
//将RGB格式数据的同步信号延迟三个时钟周期，与帧差结果同步

wire 		frame_diff_valid;
wire 		frame_diff_last;
wire 		frame_diff_user;

reg  [2:0] 	frame_diff_valid_reg;
reg  [2:0] 	frame_diff_last_reg;
reg  [2:0] 	frame_diff_user_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        frame_diff_valid_reg <= 3'd0;
        frame_diff_last_reg  <= 3'd0;
        frame_diff_user_reg  <= 3'd0;
    end
    else if( video_in_ready ) begin
        frame_diff_valid_reg <= {frame_diff_valid_reg[1:0],video_rgb_valid }; 
        frame_diff_last_reg  <= {frame_diff_last_reg[1:0], video_rgb_valid & video_rgb_last  }; 
        frame_diff_user_reg  <= {frame_diff_user_reg[1:0], video_rgb_valid & video_rgb_user  }; 
    end
end

assign frame_diff_valid = frame_diff_valid_reg[2];
assign frame_diff_last  = frame_diff_last_reg[2];
assign frame_diff_user  = frame_diff_user_reg[2];

//---------------------------------------------
//VIP 形态学——腐蚀，卷积模板尺寸3x3

wire                    vip_erosion_data              ;  
wire                    vip_erosion_valid             ;
wire                    vip_erosion_ready             ;
wire                    vip_erosion_last              ;
wire                    vip_erosion_user              ;

ikun_erosion  #(
    .AW                         (AW                     ),
    .DW                         (1                      ),
    .COLS                       (IMG_HDISP              ),
    .ROWS                       (IMG_VDISP              ),
    .M                          (3                      ),
    .N                          (3                      )
) u_ikun_erosion(
    .clk                        (clk                    ),
    .rst_n                      (rst_n                  ),

    .s_axis_video_tdata         (frame_diff_flag        ),
    .s_axis_video_tvalid        (frame_diff_valid       ),
    .s_axis_video_tready        (frame_diff_ready       ),
    .s_axis_video_tlast         (frame_diff_last        ),
    .s_axis_video_tuser         (frame_diff_user        ),
    
    .m_axis_video_tdata         (vip_erosion_data       ),
    .m_axis_video_tvalid        (vip_erosion_valid      ),
    .m_axis_video_tready        (vip_erosion_ready      ),
    .m_axis_video_tlast         (vip_erosion_last       ),
    .m_axis_video_tuser         (vip_erosion_user       )    
);

//---------------------------------------------
//VIP 形态学——膨胀，卷积模板尺寸3x3

wire                    vip_dilation_data              ;  
wire                    vip_dilation_valid             ;
wire                    vip_dilation_ready             ;
wire                    vip_dilation_last              ;
wire                    vip_dilation_user              ;

ikun_dilation #(
    .AW                         (AW                     ),
    .DW                         (1                      ),
    .COLS                       (IMG_HDISP              ),
    .ROWS                       (IMG_VDISP              ),
    .M                          (3                      ),
    .N                          (3                      )
)u_ikun_dilation(
    .clk                        (clk                    ),
    .rst_n                      (rst_n                  ),

    .s_axis_video_tdata         (vip_erosion_data       ),
    .s_axis_video_tvalid        (vip_erosion_valid      ),
    .s_axis_video_tready        (vip_erosion_ready      ),
    .s_axis_video_tlast         (vip_erosion_last       ),
    .s_axis_video_tuser         (vip_erosion_user       ),
    
    .m_axis_video_tdata         (vip_dilation_data      ),
    .m_axis_video_tvalid        (vip_dilation_valid     ),
    .m_axis_video_tready        (vip_dilation_ready     ),
    .m_axis_video_tlast         (vip_dilation_last      ),
    .m_axis_video_tuser         (vip_dilation_user      )    
);

//---------------------------------------------
//VIP 多目标检测

wire    [44:0]		target_pos_out [15:0]   ;   // {Flag,ymax[43:33],xmax[32:22],ymin[21:11],xmin[10:0]}
//wire    [ 3:0]      target_num_out          ;   //最终目标数目      

ikun_multi_target_detect  #(
    .IMG_HDISP                  (IMG_HDISP              ),   //图像水平分辨率
    .IMG_VDISP                  (IMG_VDISP              ),   //图像竖直分辨率
    .MIN_DIST                   (30                     )    //多目标领域半径
)u_ikun_multi_target_detect(
    .clk                        (clk                    ),
    .rst_n                      (rst_n                  ),
        
    .s_axis_video_tdata         (vip_dilation_data      ),
    .s_axis_video_tvalid        (vip_dilation_valid     ),
    .s_axis_video_tready        (vip_dilation_ready     ),
    .s_axis_video_tlast         (vip_dilation_last      ),
    .s_axis_video_tuser         (vip_dilation_user      ),
        
	.target_pos_out             (target_pos_out         ),	// {Flag,ymax[43:33],xmax[32:22],ymin[21:11],xmin[10:0]}
    .target_num_out             (target_num_out         )   //最终目标数目      
    );

//*****************************************************
//各目标的左/右/上/下边界

wire [15:0] target_flag;
wire [10:0] target_boarder_left 	[15:0] ;	  
wire [10:0] target_boarder_right 	[15:0] ;								 
wire [10:0] target_boarder_top		[15:0] ;								 
wire [10:0] target_boarder_bottom	[15:0] ;	

generate
genvar i; 
	for(i=0; i<16; i = i+1) begin: list    
		assign target_flag[i] 				=  target_pos_out[i][44]; 
		
		assign target_boarder_bottom[i] 	=  target_pos_out[i][43:33];	//下边界的像素坐标
		assign target_boarder_right[i] 		=  target_pos_out[i][32:22];	//右边界的像素坐标
		assign target_boarder_top[i] 		=  target_pos_out[i][21:11];	//上边界的像素坐标
		assign target_boarder_left[i] 		=  target_pos_out[i][10: 0];	//左边界的像素坐标

	end
endgenerate 

//*****************************************************
//计算摄像头输入图像的像素坐标
reg [10:0] video_in_x_cnt;    
reg [10:0] video_in_y_cnt;    

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_x_cnt <= 11'd0;
        video_in_y_cnt <= 11'd0;
    end
    else if(video_in_valid && video_in_ready) begin
        if(video_in_last) begin
             video_in_x_cnt <= 11'd0;   
             video_in_y_cnt <= video_in_y_cnt + 1'b1;   
        end
        else if(video_in_user) begin
            video_in_x_cnt <= 11'd0;       
            video_in_y_cnt <= 11'd0;
        end
        else begin
            video_in_x_cnt <= video_in_x_cnt + 1'b1;       
        end
    end  
end

//*****************************************************
//标记当前像素点是否位于边框上
reg [15:0] 	boarder_flag; 			
wire 		border_flag_final;

integer j ;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		boarder_flag <= 16'd0;
	end
	else begin 
        for(j=0; j<16; j = j+1) begin
            if(target_flag[j])begin
                if(((video_in_y_cnt == target_boarder_top[j]) || (video_in_y_cnt == target_boarder_bottom[j]))              //上下边框
                    &&((video_in_x_cnt >= target_boarder_left[j]) && (video_in_x_cnt <= target_boarder_right[j]))) begin		
                        boarder_flag[j] <= 1'b1;
                end	
                else if(((video_in_y_cnt >= target_boarder_top[j]) && (video_in_y_cnt <= target_boarder_bottom[j]))
                    &&((video_in_x_cnt == target_boarder_left[j]) || (video_in_x_cnt == target_boarder_right[j]))) begin    //左右边框
                        boarder_flag[j] <= 1'b1;
                end	 
                else begin
                    boarder_flag[j] <= 1'b0 ;	
                end	
            end
            else
                boarder_flag[j] <= 1'b0 ;
        end
    end
end

assign border_flag_final = (boarder_flag > 16'd0) ? 1'b1 : 1'b0;

//*****************************************************
//在视频流上叠加方框
reg     [DW-1: 0]       video_out_data_reg          ;
wire    [DW-1: 0]       video_out_data              ;
reg                     video_out_valid             ; 
reg                     video_out_last              ;
reg                     video_out_user              ;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_out_data_reg  <= {DW{1'b0}};
    end
    else if( video_in_ready && video_in_valid) begin
        video_out_data_reg  <= video_in_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_out_valid  <= 1'b0;
        video_out_last   <= 1'b0;
        video_out_user   <= 1'b0;
    end
    else begin
        video_out_valid  <= video_in_valid && video_in_ready;
        video_out_last   <= video_in_valid && video_in_ready && video_in_last;
        video_out_user   <= video_in_valid && video_in_ready && video_in_user;
    end
end

assign  video_out_data = border_flag_final ? 24'hff0000 : video_out_data_reg;

//*****************************************************
//输出视频流到Master接口

fifo_st_pipe_26bit_deepth16 fifo_st_pipe_26bit_deepth16 (
    .clk                (clk),          
    .rst                (~rst_n),
            
    .wr_en              (video_out_valid),        
    .din                ({video_out_user,video_out_last,video_out_data}),
    
    .rd_en              (m_axis_tvalid & m_axis_tready),        
    .dout               ({m_axis_tuser,m_axis_tlast,m_axis_tdata}),         
    .full               (fifo_pipe_full),         
    .almost_full        (fifo_pipe_almost_full),  
    .empty              (fifo_pipe_empty),        
    .data_count         (fifo_pipe_data_count)    
);

assign  m_axis_tvalid = ~fifo_pipe_empty;

endmodule