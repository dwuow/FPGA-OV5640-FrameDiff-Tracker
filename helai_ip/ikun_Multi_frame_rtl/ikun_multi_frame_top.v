
module ikun_multi_frame_top #(
	parameter VIDEO_WIDTH  = 1280,	//图像分辨率
	parameter VIDEO_HEIGHT = 720  	//	
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
	
ikun_multi_frame #(
	.IMG_HDISP(VIDEO_WIDTH ),	//图像分辨率
	.IMG_VDISP(VIDEO_HEIGHT) 	//
)u_ikun_multi_frame (
    .clk			(clk			),
    .rst_n			(rst_n			),
    .Diff_Threshold (Diff_Threshold ), 
	.target_num_out (target_num_out ),
    .s0_axis_tdata  (s0_axis_tdata  ),
    .s0_axis_tvalid (s0_axis_tvalid ),
    .s0_axis_tready (s0_axis_tready ),
    .s0_axis_tuser  (s0_axis_tuser  ),
    .s0_axis_tlast  (s0_axis_tlast  ),
            
    .s1_axis_tdata  (s1_axis_tdata  ),
    .s1_axis_tvalid (s1_axis_tvalid ),
    .s1_axis_tready (s1_axis_tready ),
    .s1_axis_tuser  (s1_axis_tuser  ),
    .s1_axis_tlast  (s1_axis_tlast  ),
            
    .m_axis_tdata	(m_axis_tdata	),
    .m_axis_tvalid	(m_axis_tvalid	),
    .m_axis_tready	(m_axis_tready	),
    .m_axis_tuser	(m_axis_tuser	),
    .m_axis_tlast   (m_axis_tlast )
    );
    
endmodule