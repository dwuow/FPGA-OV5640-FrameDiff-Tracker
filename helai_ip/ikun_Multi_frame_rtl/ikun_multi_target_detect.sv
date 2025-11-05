`timescale 1ns / 1ps

//AXI ST VIP接口的多目标检测

module ikun_multi_target_detect #(
    parameter   IMG_HDISP   =   1280,   //图像水平分辨率
    parameter   IMG_VDISP   =   720 ,   //图像竖直分辨率
    parameter   MIN_DIST    =   30      //多目标领域半径
)
(
    input                       clk,
    input                       rst_n,
        
    input   wire                s_axis_video_tdata,
    input   wire                s_axis_video_tvalid,
    output  reg                 s_axis_video_tready,
    input   wire                s_axis_video_tlast,
    input   wire                s_axis_video_tuser,

	output	reg	    [44:0]		target_pos_out [15:0],	// {Flag,ymax[43:33],xmax[32:22],ymin[21:11],xmin[10:0]}
    output  reg     [ 3:0]      target_num_out,         //最终目标数目      
    output  reg                 target_pos_valid        //目标合并完成，输出目标地址有效
    );
    
reg         video_in_data   ;
reg         video_in_valid  ; 
reg         video_in_ready  ;
reg         video_in_last   ;
reg         video_in_user   ;

reg         video_data_dly  ;
reg         video_valid_dly ; 
reg         video_last_dly  ;
reg         video_user_dly  ;

//////////////////////////////////////////////////////////step 1
//register axis input, insert bubble cycles

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_axis_video_tready <=  1'b0;
        
        video_in_data       <=  1'b0;
        video_in_valid      <=  1'b0;
        video_in_last       <=  1'b0;
        video_in_user       <=  1'b0;
    end
    else begin
        if(s_axis_video_tready) begin
            s_axis_video_tready <=  !s_axis_video_tvalid;
            
            video_in_data       <=  s_axis_video_tdata;
            video_in_valid      <=  s_axis_video_tvalid;
            video_in_last       <=  s_axis_video_tlast;
            video_in_user       <=  s_axis_video_tuser;
        end
        else if(video_in_ready) begin
            s_axis_video_tready <=  1'b1;
            
            video_in_valid      <=  1'b0;
        end
    end
end

//////////////////////////////////////////////////////////step 2
//delay for a clock cycle

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin       
        video_data_dly      <=  1'b0;
        video_valid_dly     <=  1'b0;
        video_last_dly      <=  1'b0;
        video_user_dly      <=  1'b0;
    end
    else begin
        video_data_dly      <=  video_in_valid && video_in_ready && video_in_data;
        video_valid_dly     <=  video_in_valid && video_in_ready                 ;
        video_last_dly      <=  video_in_valid && video_in_ready && video_in_last;
        video_user_dly      <=  video_in_valid && video_in_ready && video_in_user;
    end
end


//------------------------------------------
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

//------------------------------------------
//寄存坐标
reg [10:0]  x_cnt_r;
reg [10:0]  y_cnt_r;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)  begin
        x_cnt_r <= 11'd0;
		y_cnt_r <= 11'd0;
	end
	else begin
		x_cnt_r <= video_in_x_cnt;
        y_cnt_r <= video_in_y_cnt;
	end
end

//------------------------------------------
// {Flag,ymax[43:33],xmax[32:22],ymin[21:11],xmin[10:0]}
reg  [44:0]	target_pos		        [15:0] ;	//寄存各个运动目标的边界 

wire [15:0] target_flag;				        //各目标的有效标志					 
wire [10:0] target_boarder_left 	[15:0] ;	//各目标的左/右/上/下边界  
wire [10:0] target_boarder_right 	[15:0] ;								 
wire [10:0] target_boarder_top		[15:0] ;								 
wire [10:0] target_boarder_bottom	[15:0] ;	

wire [10:0] target_left 	        [15:0] ;	//各目标领域的范围  
wire [10:0] target_right 	        [15:0] ;								 
wire [10:0] target_top		        [15:0] ;								 
wire [10:0] target_bottom	        [15:0] ;	

generate
genvar i; 
	for(i=0; i<16; i = i+1) begin: list
		assign target_flag[i]           =  target_pos[i][44]; 

		assign target_boarder_bottom[i] =  target_pos[i][43:33];	//下边界的像素坐标
		assign target_boarder_right[i]  =  target_pos[i][32:22];	//右边界的像素坐标
		assign target_boarder_top[i]    =  target_pos[i][21:11];	//上边界的像素坐标
		assign target_boarder_left[i]   =  target_pos[i][10: 0];	//左边界的像素坐标
        
		assign target_bottom[i] =  (target_pos[i][43:33] < IMG_VDISP-1 - MIN_DIST  ) ? (target_pos[i][43:33] + MIN_DIST) : IMG_VDISP-1;	//下边界的像素坐标
		assign target_right[i]  =  (target_pos[i][32:22] < IMG_HDISP-1 - MIN_DIST  ) ? (target_pos[i][32:22] + MIN_DIST) : IMG_HDISP-1;	//右边界的像素坐标
		assign target_top[i]    =  (target_pos[i][21:11] > 11'd0       + MIN_DIST  ) ? (target_pos[i][21:11] - MIN_DIST) : 11'd0;		//上边界的像素坐标
		assign target_left[i]   =  (target_pos[i][10: 0] > 11'd0       + MIN_DIST  ) ? (target_pos[i][10: 0] - MIN_DIST) : 11'd0;		//左边界的像素坐标

	end
endgenerate

//------------------------------------------
//检测并标记目标需要两个像素时钟 
integer j ;
reg [ 3:0] target_cnt;
reg [15:0] new_target_flag;		//检测到新目标的投票箱	 

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		//初始化各运动目标的边界为0
		for(j=0; j<16; j = j+1) begin	
			target_pos[j] <= {1'b0,11'd0,11'd0,11'd0,11'd0};
		end
		new_target_flag	<= 16'd0;
		target_cnt 		<= 4'd0;
	end
		//在一帧开始进行初始化
	else if(video_in_valid && video_in_ready && video_in_user)begin  
		for(j=0; j<16; j = j+1) begin	
			target_pos[j] <= {1'b0,11'd0,11'd0,11'd0,11'd0};
		end
		new_target_flag	<= 16'd0;
		target_cnt 		<= 4'd0;
	end  
	else begin 
	//------------------------------------------
    //第一个时钟周期，找出标记为运动目标的像素点，由运动目标列表中的元素进行投票，判断是否为全新的运动目标
		if(video_in_valid && video_in_ready && video_in_data) begin		 
			for(j=0; j<16; j = j+1) begin
				if(target_flag[j] == 1'b0) begin		//运动目标列表中的数据无效，则该元素投票认定输入的灰度为新的最大值					
					new_target_flag[j] <= 1'b1; 
				end	
				else begin								//运动目标列表中的数据有效，则判断当前像素是否落在该元素临域里
					if((video_in_x_cnt < target_left[j]) || (video_in_x_cnt > target_right[j])
                            ||(video_in_y_cnt < target_top[j])||(video_in_y_cnt > target_bottom[j])) begin 
						new_target_flag[j] <= 1'b1;		//如果坐标距离超出目标临域范围，投票认定为新的目标
					end	
					else begin
						new_target_flag[j] <= 1'b0;		//否则不认定为新的目标	
					end
				end
			end
		end
		else begin
            new_target_flag	<= 16'd0;					//输入像素点不是运动目标 
        end  
		
        //------------------------------------------
		//第二个时钟周期，根据投票结果，将候选数据更新到运动目标列表中
		if(video_valid_dly && video_data_dly) begin 
			if(new_target_flag == 16'hffff)begin  		//全票通过，标志着出现新的运动目标 
				target_pos[target_cnt] <= {1'b1,y_cnt_r,x_cnt_r,y_cnt_r,x_cnt_r};
				target_cnt <= target_cnt + 1'b1;
			end	
			else if (new_target_flag > 16'd0)begin		//出现被标记为运动目标的像素点，但是落在运动目标列表中某个元素的临域内
			
				for(j=0; j<16; j = j+1) begin	       	//遍历运动目标列表，扩展其中各元素的临域范围
				
					if(new_target_flag[j] == 1'b0) begin //未投票认定为新目标的元素，表示当前像素位于它的临域内
					
						target_pos[j][44] 		<= 1'b1; 
						
						if(x_cnt_r < target_pos[j][10: 0] )		//若X坐标小于左边界，则将其X坐标扩展为左边界
							target_pos[j][10: 0] <= x_cnt_r ;
							
						if(x_cnt_r > target_pos[j][32:22] )		//若X坐标大于右边界，则将其X坐标扩展为右边界
							target_pos[j][32:22] <=	x_cnt_r ;
							
						if(y_cnt_r < target_pos[j][21:11] )		//若Y坐标小于上边界，则将其Y坐标扩展为上边界
							target_pos[j][21:11] <=	y_cnt_r ;
							
						if(y_cnt_r > target_pos[j][43:33] )		//若Y坐标大于下边界，则将其Y坐标扩展为下边界
							target_pos[j][43:33] <=	y_cnt_r ;

					end
				end
				
			end  
		end
	end 
end 

/////////////////////////////////////////
//一帧统计结束后，寄存输出结果
integer k;

reg [ 3:0] repet_target_cnt;    //用于排除重复的目标
reg [ 3:0] check_target_cnt;    //用于排除重复的目标
reg [ 3:0] valid_target_cnt;    //最终有效的目标数
reg [ 3:0] delete_repet_state;  //状态机，用于查找并删除重复目标

reg	[44:0] target_pos_reg[15:0];//临时寄存各坐标

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		for(k=0; k<16; k = k+1) begin	
			target_pos_out[k] <=  {1'b0,11'd0,11'd0,11'd0,11'd0};
			target_pos_reg[k] <=  {1'b0,11'd0,11'd0,11'd0,11'd0};
		end
        
        repet_target_cnt    <= 4'd0;
        check_target_cnt    <= 4'd0;
        valid_target_cnt    <= 4'd0;
        target_pos_valid    <= 1'b0;
        delete_repet_state  <= 4'd0;
        
        target_num_out      <= 4'd0;
        video_in_ready      <= 1'b1;
	end
	else begin
        case(delete_repet_state)
            4'd0: begin
                if((x_cnt_r == IMG_HDISP - 1) && (y_cnt_r == IMG_VDISP - 1))begin   //一帧统计结束后，输出寄存器清零，开始查找并删除重复目标
                    for(k=0; k<16; k = k+1) begin	
                        target_pos_out[k] <= {1'b0,11'd0,11'd0,11'd0,11'd0};
                        target_pos_reg[k] <= target_pos[k]; //寄存各目标结果
                    end
                    
                    repet_target_cnt    <= 4'd0;            //从第0个目标开始排除
                    check_target_cnt    <= 4'd1;            //由第1目标开始比较（0目标不必和自己比较）
                    valid_target_cnt    <= 4'd0;
                    target_pos_valid    <= 1'b0;
                    delete_repet_state  <= 4'd1;
                    
                    video_in_ready      <= 1'b0;
                end
            end
    
            4'd1: begin
                if(target_pos_reg[repet_target_cnt][44] == 1'b0) begin    //如果当前目标的FLAG标志位为0，则所有目标遍历完成    
                    target_pos_valid    <= 1'b1;
                    delete_repet_state  <= 4'd0;
                    
                    target_num_out      <= valid_target_cnt; //寄存最终合并之后的目标数目
                    video_in_ready      <= 1'b1;
                end
                else if(target_pos_reg[check_target_cnt][44] == 1'b0) begin    //如果比较目标的FLAG标志位为0，则当前目标检查完成    
                    delete_repet_state  <= 4'd2;
                end
                else begin  //目标有效，则与其余各目标比较，判断是否有重叠区域
                
                    //没有重叠区域，则与下一目标继续比较
                    if((target_pos_reg[repet_target_cnt][10: 0] > target_pos_reg[check_target_cnt][32:22]) ||       //左边界大于右边界
                        (target_pos_reg[repet_target_cnt][32:22] < target_pos_reg[check_target_cnt][10: 0]) ||      //右边界小于左边界
                            (target_pos_reg[repet_target_cnt][21:11] > target_pos_reg[check_target_cnt][43:33]) ||  //上边界大于下边界
                                (target_pos_reg[repet_target_cnt][43:33] < target_pos_reg[check_target_cnt][21:11]) //下边界小于上边界
                                    ) begin   
                        if(check_target_cnt < 4'd15) begin  //继续比较下一个目标
                            check_target_cnt    <= check_target_cnt + 1'b1;
                            delete_repet_state  <= 4'd1;
                        end
                        else begin
                            delete_repet_state  <= 4'd2;    //比较到最后一个目标，当前目标检查完成
                        end    
                    end
                    //有重叠区域，将当前目标的坐标合并到比较目标中，同时排除掉当前目标
                    else begin                           
						if( target_pos_reg[repet_target_cnt][10: 0] <  target_pos_reg[check_target_cnt][10: 0] )		//若X坐标小于左边界，则将其X坐标扩展为左边界
                            target_pos_reg[check_target_cnt][10: 0] <= target_pos_reg[repet_target_cnt][10: 0] ;
							
						if( target_pos_reg[repet_target_cnt][32:22] >  target_pos_reg[check_target_cnt][32:22] )		//若X坐标大于右边界，则将其X坐标扩展为右边界
							target_pos_reg[check_target_cnt][32:22] <= target_pos_reg[repet_target_cnt][32:22] ;
							
						if( target_pos_reg[repet_target_cnt][21:11]  < target_pos_reg[check_target_cnt][21:11] )		//若Y坐标小于上边界，则将其Y坐标扩展为上边界
							target_pos_reg[check_target_cnt][21:11] <= target_pos_reg[repet_target_cnt][21:11]  ;
							
						if( target_pos_reg[repet_target_cnt][43:33] >  target_pos_reg[check_target_cnt][43:33] )		//若Y坐标大于下边界，则将其Y坐标扩展为下边界
							target_pos_reg[check_target_cnt][43:33] <= target_pos_reg[repet_target_cnt][43:33] ;

                        if(repet_target_cnt < 4'd14) begin      //继续排除下一个目标
                            repet_target_cnt    <= repet_target_cnt + 1'b1;
                            check_target_cnt    <= repet_target_cnt + 4'd2;
                            delete_repet_state  <= 4'd1;
                        end
                        else begin
                            repet_target_cnt    <= repet_target_cnt + 1'b1; //最后一个目标直接输出 
                            delete_repet_state  <= 4'd2;
                        end
                    end
                end
            end
          
            4'd2: begin //目标检查完成，没有重复目标，将该目标写入最终的输出接口
                target_pos_out[valid_target_cnt] <= target_pos_reg[repet_target_cnt];
                
                valid_target_cnt        <= valid_target_cnt + 1'b1; 
                
                if(repet_target_cnt < 4'd14) begin //检查下一个目标
                    repet_target_cnt    <= repet_target_cnt + 1'b1; //最大值为14
                    check_target_cnt    <= repet_target_cnt + 4'd2; //最大值为15
                    delete_repet_state  <= 4'd1;    //继续排除
                end
                else if(repet_target_cnt == 4'd14) begin   //下一个目标为最后一个目标，不用检查，直接输出
                    repet_target_cnt    <= repet_target_cnt + 1'b1; //最后一个目标为15
                    delete_repet_state  <= 4'd2;    //直接输出
                end
                else begin
                    target_pos_valid    <= 1'b1;    //所有目标比较完成
                    delete_repet_state  <= 4'd0;
                    
                    target_num_out      <= valid_target_cnt; //寄存最终合并之后的目标数目
                    
                    video_in_ready      <= 1'b1;
                end
            end
    
        endcase
        
    end
end
    
endmodule
