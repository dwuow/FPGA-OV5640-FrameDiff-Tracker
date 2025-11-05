`timescale 1ns / 1ps

//形态学——膨胀，卷积模板尺寸3x3

module ikun_dilation #(
    parameter   AW      = 11,
    parameter   DW      = 1,
    parameter   COLS    = 1280,
    parameter   ROWS    = 720,
    parameter   M       = 3,
    parameter   N       = 3
)
(
    input                       clk,
    input                       rst_n,
        
    input   wire [DW-1: 0]      s_axis_video_tdata,
    input   wire                s_axis_video_tvalid,
    output  wire                s_axis_video_tready,
    input   wire                s_axis_video_tlast,
    input   wire                s_axis_video_tuser,
     
    output  wire [DW-1: 0]      m_axis_video_tdata,
    output  wire                m_axis_video_tvalid,
    input   wire                m_axis_video_tready,
    output  wire                m_axis_video_tlast,
    output  wire                m_axis_video_tuser    
    );
    
localparam  LATENCY = 2;

//---------------------------------------------
//获取 3x3 卷积模板 

wire    [DW-1: 0]           vip_martrix_out_martrix [M-1:0] [N-1:0] ;  
wire    [DW-1: 0]           vip_martrix_out_data                    ;  
wire                        vip_martrix_out_valid                   ;
wire                        vip_martrix_out_ready                   ;
wire                        vip_martrix_out_last                    ;
wire                        vip_martrix_out_user                    ;
    
ikun_martrix_3x3  #(
    .AW                         (AW                         ),
    .COLS                       (COLS                       ),
    .ROWS                       (ROWS                       )
)u_ikun_martrix_3x3(
    .clk                        (clk                        ),
    .rst_n                      (rst_n                      ),

    .s_axis_video_tdata         (s_axis_video_tdata         ),
    .s_axis_video_tvalid        (s_axis_video_tvalid        ),
    .s_axis_video_tready        (s_axis_video_tready        ),
    .s_axis_video_tlast         (s_axis_video_tlast         ),
    .s_axis_video_tuser         (s_axis_video_tuser         ),

    .m_axis_video_martrix       (vip_martrix_out_martrix    ),
    .m_axis_video_tdata         (vip_martrix_out_data       ),
    .m_axis_video_tvalid        (vip_martrix_out_valid      ),
    .m_axis_video_tready        (vip_martrix_out_ready      ),
    .m_axis_video_tlast         (vip_martrix_out_last       ),
    .m_axis_video_tuser         (vip_martrix_out_user       )    
);

//---------------------------------------------step 1
//3x3矩阵每行元素 “相或” 的结果
reg martrix_or_row0;
reg martrix_or_row1;
reg martrix_or_row2;

//step 1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        martrix_or_row0 <=  1'b0;
        martrix_or_row1 <=  1'b0;
        martrix_or_row2 <=  1'b0;
    end
    else if(m_axis_video_tready) begin
        martrix_or_row0 <=  vip_martrix_out_martrix[0][0] | vip_martrix_out_martrix[0][1] | vip_martrix_out_martrix[0][2];
        martrix_or_row1 <=  vip_martrix_out_martrix[0][0] | vip_martrix_out_martrix[0][1] | vip_martrix_out_martrix[0][2];
        martrix_or_row2 <=  vip_martrix_out_martrix[0][0] | vip_martrix_out_martrix[0][1] | vip_martrix_out_martrix[0][2];
    end
end

//---------------------------------------------step 2
//3x3矩阵所有元素 “相或” 的结果
reg martrix_or_full;

//step 1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        martrix_or_full <=  1'b0;
    end
    else if(m_axis_video_tready) begin
        martrix_or_full <=  martrix_or_row0 | martrix_or_row1 | martrix_or_row2;
    end
end

//---------------------------------------------step 1~2
//延迟同步信号
reg     [LATENCY-1:0]   martrix_user_reg    ;  
reg     [LATENCY-1:0]   martrix_valid_reg   ;  
reg     [LATENCY-1:0]   martrix_last_reg    ;  

//延迟LATENCY个时钟周期
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        martrix_user_reg    <= {LATENCY{1'b0}};
        martrix_valid_reg   <= {LATENCY{1'b0}};
        martrix_last_reg    <= {LATENCY{1'b0}};
    end 
    else if(m_axis_video_tready) begin
        martrix_user_reg    <= {martrix_user_reg [LATENCY-2:0],vip_martrix_out_user };
        martrix_valid_reg   <= {martrix_valid_reg[LATENCY-2:0],vip_martrix_out_valid};
        martrix_last_reg    <= {martrix_last_reg [LATENCY-2:0],vip_martrix_out_last };
    end
end      

assign  m_axis_video_tdata  = martrix_or_full;
assign  m_axis_video_tvalid = martrix_valid_reg[LATENCY-1];
assign  m_axis_video_tlast  = martrix_last_reg[LATENCY-1];
assign  m_axis_video_tuser  = martrix_user_reg[LATENCY-1];

assign  vip_martrix_out_ready   = m_axis_video_tready;

endmodule
