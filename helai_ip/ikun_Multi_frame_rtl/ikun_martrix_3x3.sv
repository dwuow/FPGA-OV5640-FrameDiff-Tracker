`timescale 1ns / 1ps

//生成大小为3x3的卷积模板，数据位宽为1bit

module ikun_martrix_3x3 #(
    parameter   AW      = 11,
    parameter   COLS    = 1280,
    parameter   ROWS    = 720
)
(
    input                       clk,
    input                       rst_n,
        
    input   wire   [0:0]        s_axis_video_tdata,
    input   wire                s_axis_video_tvalid,
    output  wire                s_axis_video_tready,
    input   wire                s_axis_video_tlast,
    input   wire                s_axis_video_tuser,

    output  reg    [0:0]        m_axis_video_martrix[2:0][2:0],
    output  reg    [0:0]        m_axis_video_tdata,
    output  reg                 m_axis_video_tvalid,
    input   wire                m_axis_video_tready,
    output  reg                 m_axis_video_tlast,
    output  reg                 m_axis_video_tuser  
    );
    
localparam  DW              = 1;
localparam  M               = 3;
localparam  N               = 3;
    
localparam  EXT_LINE_NUM    = (M-1)/2;
localparam  EXT_PIXEL_NUM   = (N-1)/2;
localparam  EXT_H_BLANK     = COLS/16;
    
reg     [AW-1: 0]       video_in_cntx               ;
reg     [AW-1: 0]       video_in_ext_cnty           ;
            
reg     [DW-1: 0]       video_in_data               ;
reg                     video_in_valid              ; 
wire                    video_in_ready              ;
reg                     video_in_last               ;
reg                     video_in_user               ;

reg     [DW-1: 0]       video_ver_data[M-1:0]       ;
reg                     video_ver_valid             ; 
reg                     video_ver_last              ;
reg                     video_ver_user              ;

reg     [DW-1: 0]       video_out_data[M-1:0][N-1:0];
reg                     video_out_valid             ; 
reg                     video_out_last              ;
reg                     video_out_user              ;
            
reg     [AW-1: 0]       ext_ver_pixel_cnt           ;
wire                    ext_video_valid             ;
wire                    ext_video_last              ;
        
reg     [AW-1: 0]       ext_hor_cntx                ;
reg     [AW-1: 0]       ext_hor_pixel_cnt           ;
wire                    ext_hor_video_valid         ;
wire                    ext_hor_video_last          ;
wire                    ext_hor_valid               ;

wire                    video_in_ext_valid          ;
wire                    video_in_ext_last           ;
        
wire                    video_in_sof                ;
reg                     fifo_rst_busy               ;
reg     [3:0]           fifo_rst_busy_cnt           ;


reg     [DW-1:0]        video_temp_martrix[2:0][2:0];
reg     [DW-1:0]        video_temp_tdata            ;
reg                     video_temp_tvalid           ;
reg                     video_temp_tready           ;
reg                     video_temp_tlast            ;
reg                     video_temp_tuser            ;


assign  video_in_sof    =   s_axis_video_tvalid & s_axis_video_tready & s_axis_video_tuser;

assign  video_in_ready  =   (video_in_ext_cnty < EXT_LINE_NUM) ? (~fifo_rst_busy) : 
                                ((video_in_ext_cnty >= ROWS) && ((video_in_ext_cnty < ROWS + EXT_LINE_NUM))) ? 1'b0 :
                                    (ext_hor_valid ? 1'b0 : video_temp_tready);

assign  s_axis_video_tready = video_in_ready;

//////////////////////////////////////////////////////////step 1
//register axis input
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_data   <= {DW{1'b0}};
    end
    else if(fifo_rst_busy) begin
        video_in_data   <= video_in_data;
    end
    else if( s_axis_video_tready && s_axis_video_tvalid) begin
        video_in_data   <= s_axis_video_tdata;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_valid  <= 1'b0;
    end
    else if(fifo_rst_busy) begin
        video_in_valid  <= video_in_valid;
    end
    else if( s_axis_video_tready ) begin
        video_in_valid  <= s_axis_video_tvalid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_last   <= 1'b0;
    end
    else if( s_axis_video_tready ) begin
        video_in_last   <= s_axis_video_tvalid & s_axis_video_tlast;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_user   <= 1'b0;
    end
    else if( s_axis_video_tready ) begin
        video_in_user   <= s_axis_video_tvalid & s_axis_video_tuser;
    end
end
    
//////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_cntx   <= {AW{1'b0}};
    end
    else if(video_in_sof) begin
        video_in_cntx   <= {AW{1'b0}};
    end
    else if(video_in_last && s_axis_video_tready) begin
        video_in_cntx   <= {AW{1'b0}};
    end
    else if(video_in_valid && s_axis_video_tready && (~fifo_rst_busy))begin
        video_in_cntx   <= video_in_cntx + 1'b1; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_in_ext_cnty   <= {AW{1'b0}};
    end
    else if(video_in_sof) begin
        video_in_ext_cnty   <= {AW{1'b0}};
    end
    else if(video_in_ext_last) begin
        video_in_ext_cnty   <= video_in_ext_cnty + 1'b1;
    end
end

//////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ext_ver_pixel_cnt   <= {AW{1'b0}};
    end
    else if(video_in_sof) begin
        ext_ver_pixel_cnt   <= {AW{1'b0}};
    end
    else if((video_in_ext_cnty >= ROWS) && (video_in_ext_cnty < ROWS + EXT_LINE_NUM)) begin
        if(ext_ver_pixel_cnt < EXT_H_BLANK + COLS) begin
            if(ext_ver_pixel_cnt < EXT_H_BLANK)
                ext_ver_pixel_cnt   <= ext_ver_pixel_cnt + 1'b1;
            else if(video_temp_tready)
                ext_ver_pixel_cnt   <= ext_ver_pixel_cnt + 1'b1;
        end
        else
            ext_ver_pixel_cnt   <= {AW{1'b0}};
    end
    else begin
        ext_ver_pixel_cnt   <= {AW{1'b0}};
    end    
end

assign  ext_video_valid = ((ext_ver_pixel_cnt >= EXT_H_BLANK) && (ext_ver_pixel_cnt <= EXT_H_BLANK + COLS-1)) ? 1'b1 : 1'b0;
assign  ext_video_last  = (ext_ver_pixel_cnt == EXT_H_BLANK + COLS-1) ? 1'b1 : 1'b0;

//assign  video_in_ext_valid  = (video_in_valid && s_axis_video_tready ) || (ext_video_valid && video_temp_tready);
assign  video_in_ext_valid  = video_in_valid || ext_video_valid;
assign  video_in_ext_last   = (video_in_last  && s_axis_video_tready ) || (ext_video_last  && video_temp_tready);  

//////////////////////////////////////////////////////////
reg                 fifo_rst;

reg     [M-1:   0]  fifo_wr;
wire    [M-1:   0]  fifo_rd;
reg     [DW-1:  0]  fifo_wr_data [M-1:0];
wire    [DW-1:  0]  fifo_rd_data [M-1:0];

wire    [M-1:   0]  fifo_full   ;
wire    [M-1:   0]  fifo_empty  ;

wire    [11 :   0]  fifo_count [M-1:0];

always @(posedge clk) begin
    if(!rst_n) begin
        fifo_rst   <=  1'b1;
    end
    else if(video_in_sof)begin
        fifo_rst   <=  1'b1;
    end
    else begin
        fifo_rst   <=  1'b0;
    end   
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_rst_busy_cnt   <=  4'd0;
    end
    else if(fifo_rst)begin
        fifo_rst_busy_cnt   <=  4'd0;
    end
    else if(fifo_rst_busy_cnt < 4'd15) begin
        fifo_rst_busy_cnt   <=  fifo_rst_busy_cnt + 1'b1;
    end   
end

assign fifo_rst_busy = (fifo_rst_busy_cnt < 4'd15) ? fifo_full[1] : fifo_rst;


assign  fifo_rd[0]      =   video_in_ext_valid && video_temp_tready;
assign  fifo_rd_data[0] =   (video_in_ext_cnty < ROWS) ? video_in_data : fifo_rd_data [1];

//unused
always @(posedge clk) begin
    fifo_wr[0]          <=   1'b0;
    fifo_wr_data[0]     <=   {DW{1'b0}};  
end
assign  fifo_full[0]    =   1'b0;
assign  fifo_empty[0]   =   1'b0;
assign  fifo_count[0]   =   12'd0;

genvar i;

generate
    for(i=1;i<M;i=i+1) begin

        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                fifo_wr[i]  <= 1'b0;
            end
            else if(video_in_ext_cnty == {AW{1'b0}}) begin
                fifo_wr[i]  <= video_in_ext_valid && video_temp_tready && (~fifo_rst_busy);
            end
            else if(video_in_ext_cnty < ROWS + EXT_LINE_NUM -1)  begin
                fifo_wr[i]  <= fifo_rd[i-1];
            end
            else begin
                fifo_wr[i]  <= 1'b0;
            end
        end
        
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                fifo_wr_data[i]  <= {DW{1'b0}};
            end
            else if(video_in_ext_cnty == {AW{1'b0}}) begin
                fifo_wr_data[i]  <= fifo_rd_data[0];
            end
            else begin
                fifo_wr_data[i]  <= fifo_rd_data[i-1];
            end    
        end
        
        assign  fifo_rd[i]  = (video_in_ext_cnty > {AW{1'b0}}) ? (video_in_ext_valid && video_temp_tready) : 1'b0;

        
        fifo_matrix_gen_1bit u_fifo_matrix_gen_1bit (
            .clk                (clk                ),              
            .rst                (fifo_rst           ),     
                
            .din                (fifo_wr_data[i]    ),  
            .wr_en              (fifo_wr[i]         ),       
            .rd_en              (fifo_rd[i]         ),       
            .dout               (fifo_rd_data[i]    ),  
            .full               (fifo_full[i]       ),        
            .almost_full        (                   ),                 
            .empty              (fifo_empty[i]      ),            
            .almost_empty       (                   ),                 

            .data_count         (fifo_count[i]      )
        );
         
    end
endgenerate
//////////////////////////////////////////////////////////step 2
//vertical padding output

genvar j;
generate
    for(j=0;j<M;j=j+1) begin
    
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                video_ver_data[j]   <= {DW{1'b0}};
            end
            else if(video_in_ext_cnty >= EXT_LINE_NUM) begin
                if(fifo_rd[j])begin
                    video_ver_data[j]   <= fifo_rd_data[j];
                end
            end
            else begin
                video_ver_data[j]   <= {DW{1'b0}};
            end
        end
                
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_ver_valid  <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_ver_valid  <= (video_in_ext_cnty >= EXT_LINE_NUM) && video_in_ext_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_ver_last   <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_ver_last   <= (video_in_ext_cnty >= EXT_LINE_NUM) && video_in_ext_valid && video_in_ext_last;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_ver_user   <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_ver_user   <= (video_in_ext_cnty == EXT_LINE_NUM) && video_in_ext_valid && (video_in_cntx == {AW{1'b0}});
    end
end

//////////////////////////////////////////////////////////
//horizon padding output

//////////////////////////////////////////////////////////


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ext_hor_pixel_cnt   <= {AW{1'b0}};
    end
    else if(video_in_sof) begin
        ext_hor_pixel_cnt   <= {AW{1'b0}};
    end
    else if(video_ver_last && video_ver_valid && video_temp_tready) begin
        ext_hor_pixel_cnt   <= ext_hor_pixel_cnt + 1'b1;
    end
    else if(ext_hor_pixel_cnt > {AW{1'b0}}) begin
        if(ext_hor_pixel_cnt <= EXT_PIXEL_NUM) begin
            if(video_temp_tready)
                ext_hor_pixel_cnt   <= ext_hor_pixel_cnt + 1'b1;
        end
        else if(ext_hor_pixel_cnt < N)
            ext_hor_pixel_cnt   <= ext_hor_pixel_cnt + 1'b1;
        else
            ext_hor_pixel_cnt   <= {AW{1'b0}};
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ext_hor_cntx   <= {AW{1'b0}};
    end
    else if(video_in_sof) begin
        ext_hor_cntx   <= {AW{1'b0}};
    end
    else if(ext_hor_video_last && video_temp_tready) begin
        ext_hor_cntx   <= {AW{1'b0}};
    end
    else if(ext_hor_video_valid && video_temp_tready)begin
        ext_hor_cntx   <= ext_hor_cntx + 1'b1; 
    end
end

assign  ext_hor_valid       = (ext_hor_pixel_cnt > 0) && (ext_hor_pixel_cnt <= EXT_PIXEL_NUM);

assign  ext_hor_video_valid = ext_hor_valid || video_ver_valid;
assign  ext_hor_video_last  = (ext_hor_pixel_cnt == EXT_PIXEL_NUM) ? 1'b1 : 1'b0;

reg     [DW-1: 0]       hor_buf_data[M-1:0][N-1:0];
wire    [DW-1: 0]       hor_buf_data_w[M-1:0][N-1:0];

genvar k,s;
generate
    for(k=0;k<M;k=k+1) begin
    
        assign hor_buf_data_w[k][0]  = (ext_hor_cntx >= COLS) ? hor_buf_data[k][1] : video_ver_data[k];
        
        always @(posedge clk) begin
            hor_buf_data[k][0]  <=  {DW{1'b0}};  
        end
        
        for(s=1;s<N;s=s+1) begin

            assign hor_buf_data_w[k][s]  = hor_buf_data[k][s];

            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    hor_buf_data[k][s]  <= {DW{1'b0}};
                end
                else if(ext_hor_video_valid && video_temp_tready) begin
                    if(ext_hor_cntx == {AW{1'b0}})
                        hor_buf_data[k][s]  <= video_ver_data[k];
                    else
                        hor_buf_data[k][s]  <= hor_buf_data_w[k][s-1];
                end
            end
        
        end
    end
endgenerate


//////////////////////////////////////////////////////////step 3~4
//axis output

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_out_valid  <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_out_valid  <= (ext_hor_cntx >= EXT_PIXEL_NUM) && ext_hor_video_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_out_last   <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_out_last   <= ext_hor_video_last && ext_hor_video_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        video_out_user   <= 1'b0;
    end
    else if( video_temp_tready ) begin
        video_out_user   <= ext_hor_video_valid && (video_in_ext_cnty == EXT_LINE_NUM) && (ext_hor_cntx == EXT_PIXEL_NUM);
    end
end

genvar p,q;
generate
    for(p=0;p<M;p=p+1) begin
        for(q=0;q<N;q=q+1) begin

            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    video_out_data[p][q]  <= {DW{1'b0}};
                end
                else if(ext_hor_video_valid && video_temp_tready && (ext_hor_cntx >= EXT_PIXEL_NUM)) begin
                    video_out_data[p][q]  <= hor_buf_data_w[p][q];
                end
            end          

        end
    end
endgenerate


//////////////////////////////////////////////////////////
//deal with m_axis_video_tready

integer x;
integer y;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        m_axis_video_tdata  <=  {DW{1'b0}};
        m_axis_video_tvalid <=  1'b0;
        m_axis_video_tlast  <=  1'b0;
        m_axis_video_tuser  <=  1'b0;
        
        video_temp_tdata    <=  {DW{1'b0}};
        video_temp_tvalid   <=  1'b0;
        video_temp_tlast    <=  1'b0;
        video_temp_tuser    <=  1'b0;
    end
    else begin
        // input is ready
        if(video_temp_tready) begin 
            // output is ready or currently not valid, transfer data to output
            if(m_axis_video_tready || !m_axis_video_tvalid) begin
                
                for(x = 0; x < M; x = x+1) begin 
                    for(y = 0; y < N; y = y+1) begin 
                        m_axis_video_martrix[x][y] = video_out_data[x][y];
                    end			
                end
                m_axis_video_tdata  <=  video_out_data[(M-1)/2][(N-1)/2];
                m_axis_video_tvalid <=  video_out_valid ;
                m_axis_video_tlast  <=  video_out_last  ;
                m_axis_video_tuser  <=  video_out_user  ;            
            end
            else begin // output is not ready, store input in temp
                
                for(x = 0; x < M; x = x+1) begin 
                    for(y = 0; y < N; y = y+1) begin 
                        video_temp_martrix[x][y] = video_out_data[x][y];
                    end			
                end           
                video_temp_tdata    <=  video_out_data[(M-1)/2][(N-1)/2];
                video_temp_tvalid   <=  video_out_valid ;
                video_temp_tlast    <=  video_out_last  ;
                video_temp_tuser    <=  video_out_user  ; 
            end
        end
        // input is not ready, but output is ready
        else if(m_axis_video_tready) begin
        
            for(x = 0; x < M; x = x+1) begin 
                for(y = 0; y < N; y = y+1) begin 
                    m_axis_video_martrix[x][y] = video_temp_martrix[x][y];
                end			
            end
            m_axis_video_tdata  <=  video_temp_tdata ;
            m_axis_video_tvalid <=  video_temp_tvalid;
            m_axis_video_tlast  <=  video_temp_tlast ;
            m_axis_video_tuser  <=  video_temp_tuser ;
            
            video_temp_tvalid   <=  1'b0 ;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        video_temp_tready   <=  1'b0;
    else begin
        // enable ready input next cycle if output is ready 
        if(m_axis_video_tready)
            video_temp_tready   <=  1'b1;
        // enable ready input the temp reg will not be filled on the next cycle (output reg empty or no input) 
        else if(!video_temp_tvalid && (!m_axis_video_tvalid || !video_out_valid))
            video_temp_tready   <=  1'b1;        
        else 
            video_temp_tready   <=  1'b0;
    end
end

endmodule 