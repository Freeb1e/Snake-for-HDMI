module vga_shift(         
input	wire			  rst     		,//复位
input	wire			  vpg_pclk    	,//像素时钟
output	reg			  	  vpg_de      	,//输出数据有效信号
output	reg			      vpg_hs      	,//行同步信号
output	reg			      vpg_vs      	,//场同步信号
output	wire      [7:0]	  rgb_r        	,//输出图像值
output	wire      [7:0]	  rgb_g        	,//输出图像值
output	wire      [7:0]	  rgb_b        	,//输出图像值
//接收贪吃蛇头和身体的坐标
  input wire [4:0] block_x0,
  input wire [4:0] block_y0,
  input wire [4:0] block_x1,
  input wire [4:0] block_y1,
  input wire [4:0] block_x2,
  input wire [4:0] block_y2,
  input wire [4:0] block_x3,
  input wire [4:0] block_y3,
  input wire [4:0] block_x4,
  input wire [4:0] block_y4,
  input wire [4:0] block_x5,
  input wire [4:0] block_y5,
  input wire [4:0] block_x6,
  input wire [4:0] block_y6,
  input wire [4:0] block_x7,
  input wire [4:0] block_y7,
  input wire [4:0] block_x8,
  input wire [4:0] block_y8,
  input wire [4:0] block_x9,
  input wire [4:0] block_y9,
  input wire [4:0] block_x10,
  input wire [4:0] block_y10,
  input wire [4:0] block_x11,
  input wire [4:0] block_y11,
  input wire [4:0] block_x12,
  input wire [4:0] block_y12,
  input wire [4:0] block_x13,
  input wire [4:0] block_y13,
  input wire [4:0] block_x14,
  input wire [4:0] block_y14,
  input wire [4:0] block_x15,
  input wire [4:0] block_y15,
  input wire [4:0] block_x16,
  input wire [4:0] block_y16,
  input wire [4:0] block_x17,
  input wire [4:0] block_y17,
  input wire [4:0] block_x18,
  input wire [4:0] block_y18,
  input wire [4:0] block_x19,
  input wire [4:0] block_y19,
  input wire [4:0] apple_xr,
  input wire [4:0] apple_yr,
  input wire [4:0] lenth,
  input wire  gameover,
  input wire  [1:0]mode
);

parameter       H_TOTAL = 2200 - 1  ;//一行总共需要计数的值
parameter       H_SYNC = 44 - 1     ;//行同步计数值
parameter       H_START = 190 - 1   ;//行图像数据有效开始计数值
parameter       H_END = 2110 - 1    ;//行图像数据有效结束计数值
parameter       V_TOTAL = 1125 - 1  ;//场总共需要计数的值
parameter       V_SYNC = 5 - 1      ;//场同步计数值
parameter       V_START = 41 - 1    ;//场图像数据有效开始计数值
parameter       V_END = 1121 - 1    ;//场图像数据有效结束计数值
parameter       SCREEN_X    =   1920;//屏幕水平长度
parameter       SCREEN_Y    =   1080;//屏幕垂直长度
parameter       BORDER      =   40;//边框宽度

//4字符横竖宽度深度
parameter   CHAR_W   = 256 ,//字符宽度
            CHAR_H   = 64  ;//字符深度           
//单个数字宽度深度
parameter   CHAR_W0   = 32 ,//字符宽度
            CHAR_H0   = 64  ;//字符深度
//2字符宽度深度
parameter   CHAR_W_score   = 128 ,//字符宽度
            CHAR_H_score   = 64  ;//字符深度
//3字符宽度深度          
parameter   CHAR_W_snake   = 192 ,//字符宽度
            CHAR_H_snake   = 64  ;//字符深度
            
//“结束游戏”位置
parameter   CHAR_B_H = 1021 ,//字符开始横坐标
            CHAR_B_V = 548 ;//字符开始纵坐标             
//两位数字位置            
parameter   CHAR_B_H0 = 250 ,//字符开始横坐标
            CHAR_B_V0 = 548 ,//字符开始纵坐标
            CHAR_B_H01 = 290 ;//字符开始横坐标
 //“得分”位置           
parameter   CHAR_B_H_score = 220 ,//字符开始横坐标
            CHAR_B_V_score = 450 ;//字符开始纵坐标           
//模式位置
parameter   CHAR_B_H_mode = 220 ,//字符开始横坐标
            CHAR_B_V_mode_1 = 900 ,//字符开始纵坐标
            CHAR_B_V_mode_2 = 980;//字符开始纵坐标           
//“游戏”位置
parameter   CHAR_B_H_game = 232 ,//字符开始横坐标
            CHAR_B_V_game = 130 ;//字符开始纵坐标           
//“贪吃蛇”位置
parameter   CHAR_B_H_snake = 200 ,//字符开始横坐标
            CHAR_B_V_snake = 56 ;//字符开始纵坐标
 
//reg direction; 
//=======================================================
//  Signal declarations
//=======================================================
reg [12:0]	cnt_h;//行计数器
reg [12:0]	cnt_v;//场计数器
reg [11:0]	x    ;//方块左上角横坐标
reg 		flag_x;//方块水平移动方向指示信号
reg [11:0]	y    ;//方块左上角纵坐标
reg 		flag_y;//方块垂直移动方向指示信号
reg [23:0]	rgb 	;
integer i;
assign {rgb_r,rgb_g,rgb_b} = rgb;

//字符横纵坐标
wire    [9:0]    char_x    ;
wire    [9:0]    char_y    ;
wire    [9:0]    char_x0    ;
wire    [9:0]    char_y0    ;
 wire    [9:0]    char_x01;
 wire    [9:0]    char_y01    ;
 wire    [9:0]    char_x_score;
 wire    [9:0]    char_y_score;
 wire    [9:0]    char_x_mode_1;
 wire    [9:0]    char_y_mode_1;
 wire    [9:0]    char_x_mode_2;
 wire    [9:0]    char_y_mode_2;
 wire    [9:0]    char_x_game;
 wire    [9:0]    char_y_game;
 wire    [9:0]    char_x_snake;
 wire    [9:0]    char_y_snake;
 
 //字符数组
reg     [255:0]  char [63:0]  ;
reg     [63:0]  char0 [63:0]  ;
reg     [63:0]  char1 [63:0]  ;
reg     [63:0]  char2 [63:0]  ;
reg     [63:0]  char3 [63:0]  ;
reg     [63:0]  char4 [63:0]  ;
reg     [63:0]  char5 [63:0]  ;
reg     [63:0]  char6 [63:0]  ;
reg     [63:0]  char7 [63:0]  ;
reg     [63:0]  char8 [63:0]  ;
reg     [63:0]  char9 [63:0]  ;
reg     [127:0]  char_score [63:0]  ;
reg     [127:0]  char_mode [63:0]  ;
reg     [127:0]  char_mode1 [63:0]  ;
reg     [127:0]  char_mode2 [63:0]  ;
reg     [127:0]  char_mode3 [63:0]  ;
reg     [127:0]  char_mode4 [63:0]  ;
reg     [127:0]  char_game [63:0]  ;
reg     [191:0]  char_snake [63:0]  ;

assign char_x = (((cnt_h >= CHAR_B_H)&&(cnt_h < (CHAR_B_H + CHAR_W)))
                &&((cnt_v >= CHAR_B_V)&&(cnt_v < (CHAR_B_V + CHAR_H))))
                ? (cnt_h - CHAR_B_H) : 10'h3ff;
assign char_y = (((cnt_h >= CHAR_B_H)&&(cnt_h < (CHAR_B_H + CHAR_W)))
                &&((cnt_v >= CHAR_B_V)&&(cnt_v < (CHAR_B_V + CHAR_H))))
                ? (cnt_v - CHAR_B_H) : 10'h3ff;
                
assign char_x0 = (((cnt_h >= CHAR_B_H0)&&(cnt_h < (CHAR_B_H0 + CHAR_W0)))
                &&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))
                ? (cnt_h - CHAR_B_H0) : 10'h3ff;               
assign char_y0 = (((cnt_h >= CHAR_B_H0)&&(cnt_h < (CHAR_B_H0 + CHAR_W0)))
                &&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))
                ? (cnt_v - CHAR_B_H0) : 10'h3ff;
                
assign char_x01 = (((cnt_h >= CHAR_B_H01)&&(cnt_h < (CHAR_B_H01 + CHAR_W0)))
                &&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))
                ? (cnt_h - CHAR_B_H01) : 10'h3ff;                                
assign char_y01 = (((cnt_h >= CHAR_B_H01)&&(cnt_h < (CHAR_B_H01 + CHAR_W0)))
                &&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))
                ? (cnt_v - CHAR_B_H01) : 10'h3ff;

assign char_x_score = (((cnt_h >= CHAR_B_H_score)&&(cnt_h < (CHAR_B_H_score + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_score)&&(cnt_v < (CHAR_B_V_score + CHAR_H_score))))
                ? (cnt_h - CHAR_B_H_score) : 10'h3ff;
assign char_y_score = (((cnt_h >= CHAR_B_H_score)&&(cnt_h < (CHAR_B_H_score + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_score)&&(cnt_v < (CHAR_B_V_score + CHAR_H_score))))
                ? (cnt_v - CHAR_B_H_score) : 10'h3ff;
                
assign char_x_mode_1 = (((cnt_h >= CHAR_B_H_mode)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_mode_1)&&(cnt_v < (CHAR_B_V_mode_1 + CHAR_H_score))))
                ? (cnt_h - CHAR_B_H_mode) : 10'h3ff;
assign char_y_mode_1 = (((cnt_h >= CHAR_B_H_mode)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_mode_1)&&(cnt_v < (CHAR_B_V_mode_1 + CHAR_H_score))))
                ? (cnt_v - CHAR_B_H_mode) : 10'h3ff;
                
assign char_x_mode_2 = (((cnt_h >= CHAR_B_H_mode)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_mode_2)&&(cnt_v < (CHAR_B_V_mode_2 + CHAR_H_score))))
                ? (cnt_h - CHAR_B_H_mode) : 10'h3ff;
assign char_y_mode_2 = (((cnt_h >= CHAR_B_H_mode)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_mode_2)&&(cnt_v < (CHAR_B_V_mode_2 + CHAR_H_score))))
                ? (cnt_v - CHAR_B_H_mode) : 10'h3ff;
                
assign char_x_game = (((cnt_h >= CHAR_B_H_game)&&(cnt_h < (CHAR_B_H_game + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_game)&&(cnt_v < (CHAR_B_V_game + CHAR_H_score))))
                ? (cnt_h - CHAR_B_H_game) : 10'h3ff;
assign char_y_game = (((cnt_h >= CHAR_B_H_game)&&(cnt_h < (CHAR_B_H_game + CHAR_W_score)))
                &&((cnt_v >= CHAR_B_V_game)&&(cnt_v < (CHAR_B_V_game + CHAR_H_score))))
                ? (cnt_v - CHAR_B_H_game) : 10'h3ff;
                
assign char_x_snake = (((cnt_h >= CHAR_B_H_snake)&&(cnt_h < (CHAR_B_H_snake + CHAR_W_snake)))
                &&((cnt_v >= CHAR_B_V_snake)&&(cnt_v < (CHAR_B_V_snake + CHAR_H_snake))))
                ? (cnt_h - CHAR_B_H_snake) : 10'h3ff;
assign char_y_snake = (((cnt_h >= CHAR_B_H_snake)&&(cnt_h < (CHAR_B_H_snake + CHAR_W_snake)))
                &&((cnt_v >= CHAR_B_V_snake)&&(cnt_v < (CHAR_B_V_snake + CHAR_H_snake))))
                ? (cnt_v - CHAR_B_H_snake) : 10'h3ff;

//计算分数
reg   [4:0]score[1:0];
always@(posedge vpg_pclk)begin
    if (rst==1'b1) begin
		score[0]<=0;
		score[1]<=0;
	end
	else if(lenth<=5'd10)begin
	score[0]<=lenth-1;
	score[1]<=0;
	end
	else if((lenth>5'd10)&&(lenth<=5'd20))begin
	score[0]<=lenth-5'd11;
	score[1]<=1;
	end
	else begin
	score[0]<=score[0];
	score[1]<=score[1];
	end
	end

//行计数器
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		cnt_h <= 'd0;
	end
	else if (cnt_h == H_TOTAL) begin//计数到最大值，清零
		cnt_h <= 'd0;
	end
	else if(cnt_h != H_TOTAL) begin//还没有计数到最大值，每个时钟周期加一
		cnt_h <= cnt_h + 1'b1;
	end
end

//场计数器
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		cnt_v <='d0;
	end
	else if (cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin//场计数器计数到最大值，清零（一帧结束）
		cnt_v <= 'd0;
	end
	else if(cnt_h == H_TOTAL) begin//一行扫描结束，场计数器加一
		cnt_v <= cnt_v + 1'b1;
	end
end

//行同步信号
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		vpg_hs <= 1'b1;
	end
	else if (cnt_h == H_TOTAL) begin
		vpg_hs <= 1'b1;
	end
	else if (cnt_h == H_SYNC) begin
		vpg_hs <= 1'b0;
	end
end

//场同步信号
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		vpg_vs <= 1'b1;
	end
	else if (cnt_v == V_TOTAL && cnt_h == H_TOTAL) begin
		vpg_vs <= 1'b1;
	end 
	else if (cnt_v == V_SYNC && cnt_h == H_TOTAL) begin
		vpg_vs <=  1'b0;
	end
end

always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		vpg_de <= 1'b0;
	end
	else if ((cnt_h >= H_START) && (cnt_h < H_END) && (cnt_v >= V_START) && (cnt_v < V_END)) begin
		vpg_de <= 1'b1;
	end 
	else begin
		vpg_de <=  1'b0;
	end
end

always @(posedge vpg_pclk) begin
    char[0]  <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
    char[1]  <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
    char[2]  <= 256'h0000000000000000000000000000000000000000008000000000000200000000;
    char[3]  <= 256'h000000000010000000000000400000000001000000E000000000000380000000;
    char[4]  <= 256'h00000000001C000000000000780000000001C00000F8000000000003E0000000;
    char[5]  <= 256'h00C00300001F0000000000007E0000000001F00000FC000000000003E0000000;
    char[6]  <= 256'h00700180003E0000000000007E0000000003F00000F0000000000003C0000000;
    char[7]  <= 256'h007C01E0003C0000000000007C0000000003C00000F0000000000003C0000000;
    char[8]  <= 256'h003E00F000380000000000007C1C00000003C00000F0000000000003C0000100;
    char[9]  <= 256'h001F007800780000000000003C0F80000007800000F0000000000003C0000380;
    char[10] <= 256'h001F007C00700000000000003C07E0000007800000F0000000000003C00007C0;
    char[11] <= 256'h000F003C00700080000000003C03F0000007000000F000000FFFFFFFFFFFFFE0;
    char[12] <= 256'h000F003800E00180000000003C01F800000E000000F0000007FFFFFFFFFFFFF0;
    char[13] <= 256'h0006003800E003C0000001803C00FC00000E000000F0018002000003C0000000;
    char[14] <= 256'h0000000001FFFFE0000003C03C007C00001C000000F003C000000003C0000000;
    char[15] <= 256'h0000000081FFFFF00FFFFFE03C003800001C003FFFFFFFE000000003C0000000;
    char[16] <= 256'h00002001C180000007FFFFE03C0038000018001FFFFFFFF000000003C0000000;
    char[17] <= 256'h00007FFFE3000000020007C01C0010000038038800F0000000000003C0000000;
    char[18] <= 256'h10005FFFF3000000000007801C000180003003C000F0000000000003C000C000;
    char[19] <= 256'h1C004DC006000000000007801E0001C0006007E000F00000000C0003C000E000;
    char[20] <= 256'h0F00C1C00C000100000007801E0003E00060078000F00000000FFFFFFFFFF800;
    char[21] <= 256'h078081C008000380000007801E000FF000C00F0000F00000000FFFFFFFFFF800;
    char[22] <= 256'h07C081C013FFFFC000000F001E1FFFC001C01F0000F00000000F0003C001E000;
    char[23] <= 256'h03E181C011FFFFE000000F003FFF000001801E0000F00000000F0003C001E000;
    char[24] <= 256'h03E181C000C007C002000FFFFE00000003003C0000F00000000F0003C001E000;
    char[25] <= 256'h01E101C000000F0003000E7C0E0000000FFFF80000F00400000F0003C001E000;
    char[26] <= 256'h01E301C060001C0001801E200F00000007FFF00000F00C00000F0003C001E000;
    char[27] <= 256'h00C301FFF000380000E01E000F00080007F0F00000F01E00000F0003C001E000;
    char[28] <= 256'h008301FFF800600000701E000F001C000380E00FFFFFFF00000F0003C001E000;
    char[29] <= 256'h000201C0F002400000381C000F001E000201C007FFFFFF80000F0003C001E000;
    char[30] <= 256'h000601C0E0038000001C3C000F003F000003800300000000000F0003C001E000;
    char[31] <= 256'h000601C0E003E000000E3C0007003E000003000000000000000F0003C001E000;
    char[32] <= 256'h000603C0E003C0000007380007807C000007000000000000000F0003C001E000;
    char[33] <= 256'h000C03C0E003C0000007F8000780F800000E000000000000000F0003C001E000;
    char[34] <= 256'h000C0380E003C0000003F8000780F000001C000000000000000FFFFFFFFFE000;
    char[35] <= 256'h000C0380E003C0C00001F0000381F0000038000200000400000FFFFFFFFFE000;
    char[36] <= 256'h001C0380E003C1E00000F0000383E0000030000300000E00000F003FD001E000;
    char[37] <= 256'h00180380EFFFFFE00001F80003C7C00000600FE3FFFFFF00000F007FD801E000;
    char[38] <= 256'h00380380E7FFFFF00001FC0003C7800001C3FE03FFFFFF80000F007BC801C000;
    char[39] <= 256'h00380700E203C0000003FE0001CF800003FFF003C0001F00000F00FBCC010000;
    char[40] <= 256'h00780700E003C00000039F0001FF000003FF0003C0001E00000C01F3C6000000;
    char[41] <= 256'h1FF00701C003C00000039F0001FE000003F80003C0001E00000001E3C7000000;
    char[42] <= 256'h07F00701C003C00000070F8000FC002001E00003C0001E00000003E3C3000000;
    char[43] <= 256'h01F00E01C003C000000F07C000F8002000800003C0001E00000007C3C3800000;
    char[44] <= 256'h00F00E01C003C000000E07C001F0002000000003C0001E0000000F83C1C00000;
    char[45] <= 256'h00F00E01C003C000001C03E003F8002000000003C0001E0000000F03C0E00000;
    char[46] <= 256'h00F01C01C003C000001C03E007FC002000000013C0001E0000001E03C0700000;
    char[47] <= 256'h00F01C01C003C000003801E00FBE0060000000F3C0001E0000003C03C07C0000;
    char[48] <= 256'h00F03801C003C000003001E01F1E006000000783C0001E0000007803C03E0000;
    char[49] <= 256'h01F03803C003C000007000C03C0F006000007E03C0001E000000F003C01F8000;
    char[50] <= 256'h01E070038003C00000E000C0780F80600003F803C0001E000001E003C00FC000;
    char[51] <= 256'h01E070038003C00000C00000F007C0E0007FC003C0001E000003C003C007F000;
    char[52] <= 256'h01E0E0038003C00001800003C003F0E00FFF0003C0001E00000F8003C003FE00;
    char[53] <= 256'h01E0C0078003C000038000078001F8E00FFC0003FFFFFE00001E0003C001FFC0;
    char[54] <= 256'h01E183FF8003C0000700000E0000FEE007F00003FFFFFE00003C0003C0007FF0;
    char[55] <= 256'h00E380FF01FFC0000600003800007FE007C00003C0001E0000700003C0003FC0;
    char[56] <= 256'h0063007E007FC0000C00007000003FE003000003C0001E0001E00003C0000F00;
    char[57] <= 256'h0006003E001F8000180001C000001FE002000003C0001E0003800003C0000600;
    char[58] <= 256'h000C0038000F800030000700000007F000000003C0001E000E000003C0000000;
    char[59] <= 256'h001800000007000000000400000001F0000000038000180018000003C0000000;
    char[60] <= 256'h0010000000000000000000000000003800000002000000000000000380000000;
    char[61] <= 256'h0000000000000000000000000000000000000000000000000000000200000000;
    char[62] <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
    char[63] <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
end

always @(posedge vpg_pclk) begin
    char0[0]  <= 32'h00000000;
    char0[1]  <= 32'h00000000;
    char0[2]  <= 32'h00000000;
    char0[3]  <= 32'h00000000;
    char0[4]  <= 32'h00000000;
    char0[5]  <= 32'h00000000;
    char0[6]  <= 32'h00000000;
    char0[7]  <= 32'h00000000;
    char0[8]  <= 32'h00000000;
    char0[9]  <= 32'h00000000;
    char0[10] <= 32'h00000000;
    char0[11] <= 32'h0007E000;
    char0[12] <= 32'h001FF800;
    char0[13] <= 32'h003C1E00;
    char0[14] <= 32'h00700F00;
    char0[15] <= 32'h00E00700;
    char0[16] <= 32'h01E00380;
    char0[17] <= 32'h03C003C0;
    char0[18] <= 32'h03C001C0;
    char0[19] <= 32'h078001E0;
    char0[20] <= 32'h078000E0;
    char0[21] <= 32'h070000E0;
    char0[22] <= 32'h0F0000F0;
    char0[23] <= 32'h0F0000F0;
    char0[24] <= 32'h0F0000F0;
    char0[25] <= 32'h0F000070;
    char0[26] <= 32'h1E000078;
    char0[27] <= 32'h1E000078;
    char0[28] <= 32'h1E000078;
    char0[29] <= 32'h1E000078;
    char0[30] <= 32'h1E000078;
    char0[31] <= 32'h1E000078;
    char0[32] <= 32'h1E000078;
    char0[33] <= 32'h1E000078;
    char0[34] <= 32'h1E000078;
    char0[35] <= 32'h1E000078;
    char0[36] <= 32'h1E000078;
    char0[37] <= 32'h1E000078;
    char0[38] <= 32'h1E000078;
    char0[39] <= 32'h1E000078;
    char0[40] <= 32'h0F000070;
    char0[41] <= 32'h0F0000F0;
    char0[42] <= 32'h0F0000F0;
    char0[43] <= 32'h0F0000F0;
    char0[44] <= 32'h070000E0;
    char0[45] <= 32'h078001E0;
    char0[46] <= 32'h078001E0;
    char0[47] <= 32'h03C001C0;
    char0[48] <= 32'h03C003C0;
    char0[49] <= 32'h01E00380;
    char0[50] <= 32'h00E00700;
    char0[51] <= 32'h00700F00;
    char0[52] <= 32'h003C1E00;
    char0[53] <= 32'h001FF800;
    char0[54] <= 32'h0007E000;
    char0[55] <= 32'h00000000;
    char0[56] <= 32'h00000000;
    char0[57] <= 32'h00000000;
    char0[58] <= 32'h00000000;
    char0[59] <= 32'h00000000;
    char0[60] <= 32'h00000000;
    char0[61] <= 32'h00000000;
    char0[62] <= 32'h00000000;
    char0[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
char1[0]  <= 32'h00000000;
char1[1]  <= 32'h00000000;
char1[2]  <= 32'h00000000;
char1[3]  <= 32'h00000000;
char1[4]  <= 32'h00000000;
char1[5]  <= 32'h00000000;
char1[6]  <= 32'h00000000;
char1[7]  <= 32'h00000000;
char1[8]  <= 32'h00000000;
char1[9]  <= 32'h00000000;
char1[10]  <= 32'h00000000;
char1[11]  <= 32'h00004000;
char1[12]  <= 32'h0000C000;
char1[13]  <= 32'h0001C000;
char1[14]  <= 32'h0007C000;
char1[15]  <= 32'h01FFC000;
char1[16]  <= 32'h01FFC000;
char1[17]  <= 32'h0007C000;
char1[18]  <= 32'h0003C000;
char1[19]  <= 32'h0003C000;
char1[20]  <= 32'h0003C000;
char1[21]  <= 32'h0003C000;
char1[22]  <= 32'h0003C000;
char1[23]  <= 32'h0003C000;
char1[24]  <= 32'h0003C000;
char1[25]  <= 32'h0003C000;
char1[26]  <= 32'h0003C000;
char1[27]  <= 32'h0003C000;
char1[28]  <= 32'h0003C000;
char1[29]  <= 32'h0003C000;
char1[30]  <= 32'h0003C000;
char1[31]  <= 32'h0003C000;
char1[32]  <= 32'h0003C000;
char1[33]  <= 32'h0003C000;
char1[34]  <= 32'h0003C000;
char1[35]  <= 32'h0003C000;
char1[36]  <= 32'h0003C000;
char1[37]  <= 32'h0003C000;
char1[38]  <= 32'h0003C000;
char1[39]  <= 32'h0003C000;
char1[40]  <= 32'h0003C000;
char1[41]  <= 32'h0003C000;
char1[42]  <= 32'h0003C000;
char1[43]  <= 32'h0003C000;
char1[44]  <= 32'h0003C000;
char1[45]  <= 32'h0003C000;
char1[46]  <= 32'h0003C000;
char1[47]  <= 32'h0003C000;
char1[48]  <= 32'h0003C000;
char1[49]  <= 32'h0003C000;
char1[50]  <= 32'h0003C000;
char1[51]  <= 32'h0007E000;
char1[52]  <= 32'h000FF000;
char1[53]  <= 32'h01FFFF80;
char1[54]  <= 32'h01FFFF80;
char1[55]  <= 32'h00000000;
char1[56]  <= 32'h00000000;
char1[57]  <= 32'h00000000;
char1[58]  <= 32'h00000000;
char1[59]  <= 32'h00000000;
char1[60]  <= 32'h00000000;
char1[61]  <= 32'h00000000;
char1[62]  <= 32'h00000000;
char1[63]  <= 32'h00000000;
end

always @(posedge vpg_pclk) begin
    char2[0]  <= 32'h00000000;
    char2[1]  <= 32'h00000000;
    char2[2]  <= 32'h00000000;
    char2[3]  <= 32'h00000000;
    char2[4]  <= 32'h00000000;
    char2[5]  <= 32'h00000000;
    char2[6]  <= 32'h00000000;
    char2[7]  <= 32'h00000000;
    char2[8]  <= 32'h00000000;
    char2[9]  <= 32'h00000000;
    char2[10] <= 32'h00000000;
    char2[11] <= 32'h000FF000;
    char2[12] <= 32'h003FFE00;
    char2[13] <= 32'h00F81F00;
    char2[14] <= 32'h01E00780;
    char2[15] <= 32'h03C003C0;
    char2[16] <= 32'h078001E0;
    char2[17] <= 32'h070001E0;
    char2[18] <= 32'h070000F0;
    char2[19] <= 32'h0F0000F0;
    char2[20] <= 32'h0F8000F0;
    char2[21] <= 32'h0F8000F0;
    char2[22] <= 32'h0FC000F0;
    char2[23] <= 32'h0FC000F0;
    char2[24] <= 32'h0FC000F0;
    char2[25] <= 32'h078001E0;
    char2[26] <= 32'h000001E0;
    char2[27] <= 32'h000001E0;
    char2[28] <= 32'h000003C0;
    char2[29] <= 32'h000003C0;
    char2[30] <= 32'h00000780;
    char2[31] <= 32'h00000F00;
    char2[32] <= 32'h00000E00;
    char2[33] <= 32'h00001C00;
    char2[34] <= 32'h00003800;
    char2[35] <= 32'h00007000;
    char2[36] <= 32'h0000E000;
    char2[37] <= 32'h0001C000;
    char2[38] <= 32'h00038000;
    char2[39] <= 32'h00070000;
    char2[40] <= 32'h000E0000;
    char2[41] <= 32'h001C0000;
    char2[42] <= 32'h00380000;
    char2[43] <= 32'h00700000;
    char2[44] <= 32'h00E00030;
    char2[45] <= 32'h01C00030;
    char2[46] <= 32'h03800030;
    char2[47] <= 32'h07800030;
    char2[48] <= 32'h07000060;
    char2[49] <= 32'h0E0000E0;
    char2[50] <= 32'h1C0001E0;
    char2[51] <= 32'h1FFFFFE0;
    char2[52] <= 32'h1FFFFFE0;
    char2[53] <= 32'h1FFFFFE0;
    char2[54] <= 32'h1FFFFFE0;
    char2[55] <= 32'h00000000;
    char2[56] <= 32'h00000000;
    char2[57] <= 32'h00000000;
    char2[58] <= 32'h00000000;
    char2[59] <= 32'h00000000;
    char2[60] <= 32'h00000000;
    char2[61] <= 32'h00000000;
    char2[62] <= 32'h00000000;
    char2[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char3[0]  <= 32'h00000000;
    char3[1]  <= 32'h00000000;
    char3[2]  <= 32'h00000000;
    char3[3]  <= 32'h00000000;
    char3[4]  <= 32'h00000000;
    char3[5]  <= 32'h00000000;
    char3[6]  <= 32'h00000000;
    char3[7]  <= 32'h00000000;
    char3[8]  <= 32'h00000000;
    char3[9]  <= 32'h00000000;
    char3[10] <= 32'h00000000;
    char3[11] <= 32'h000FE000;
    char3[12] <= 32'h007FF800;
    char3[13] <= 32'h00E07C00;
    char3[14] <= 32'h01801E00;
    char3[15] <= 32'h03000F00;
    char3[16] <= 32'h03000780;
    char3[17] <= 32'h07000780;
    char3[18] <= 32'h070007C0;
    char3[19] <= 32'h078003C0;
    char3[20] <= 32'h078003C0;
    char3[21] <= 32'h078003C0;
    char3[22] <= 32'h030003C0;
    char3[23] <= 32'h000003C0;
    char3[24] <= 32'h000003C0;
    char3[25] <= 32'h00000780;
    char3[26] <= 32'h00000780;
    char3[27] <= 32'h00000F00;
    char3[28] <= 32'h00000E00;
    char3[29] <= 32'h00003C00;
    char3[30] <= 32'h0000F800;
    char3[31] <= 32'h000FE000;
    char3[32] <= 32'h000FF800;
    char3[33] <= 32'h00007C00;
    char3[34] <= 32'h00000F00;
    char3[35] <= 32'h00000780;
    char3[36] <= 32'h000003C0;
    char3[37] <= 32'h000001C0;
    char3[38] <= 32'h000001E0;
    char3[39] <= 32'h000000E0;
    char3[40] <= 32'h000000F0;
    char3[41] <= 32'h000000F0;
    char3[42] <= 32'h000000F0;
    char3[43] <= 32'h038000F0;
    char3[44] <= 32'h07C000F0;
    char3[45] <= 32'h0FC000F0;
    char3[46] <= 32'h0FC000F0;
    char3[47] <= 32'h0FC001E0;
    char3[48] <= 32'h0F8001E0;
    char3[49] <= 32'h078003C0;
    char3[50] <= 32'h07800380;
    char3[51] <= 32'h03C00700;
    char3[52] <= 32'h01F01E00;
    char3[53] <= 32'h007FFC00;
    char3[54] <= 32'h001FE000;
    char3[55] <= 32'h00000000;
    char3[56] <= 32'h00000000;
    char3[57] <= 32'h00000000;
    char3[58] <= 32'h00000000;
    char3[59] <= 32'h00000000;
    char3[60] <= 32'h00000000;
    char3[61] <= 32'h00000000;
    char3[62] <= 32'h00000000;
    char3[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char4[0]  <= 32'h00000000;
    char4[1]  <= 32'h00000000;
    char4[2]  <= 32'h00000000;
    char4[3]  <= 32'h00000000;
    char4[4]  <= 32'h00000000;
    char4[5]  <= 32'h00000000;
    char4[6]  <= 32'h00000000;
    char4[7]  <= 32'h00000000;
    char4[8]  <= 32'h00000000;
    char4[9]  <= 32'h00000000;
    char4[10] <= 32'h00000000;
    char4[11] <= 32'h00000E00;
    char4[12] <= 32'h00000E00;
    char4[13] <= 32'h00001E00;
    char4[14] <= 32'h00003E00;
    char4[15] <= 32'h00003E00;
    char4[16] <= 32'h00007E00;
    char4[17] <= 32'h0000FE00;
    char4[18] <= 32'h0000DE00;
    char4[19] <= 32'h00019E00;
    char4[20] <= 32'h00039E00;
    char4[21] <= 32'h00031E00;
    char4[22] <= 32'h00071E00;
    char4[23] <= 32'h00061E00;
    char4[24] <= 32'h000C1E00;
    char4[25] <= 32'h001C1E00;
    char4[26] <= 32'h00181E00;
    char4[27] <= 32'h00301E00;
    char4[28] <= 32'h00701E00;
    char4[29] <= 32'h00601E00;
    char4[30] <= 32'h00C01E00;
    char4[31] <= 32'h01C01E00;
    char4[32] <= 32'h01801E00;
    char4[33] <= 32'h03001E00;
    char4[34] <= 32'h03001E00;
    char4[35] <= 32'h06001E00;
    char4[36] <= 32'h0E001E00;
    char4[37] <= 32'h0C001E00;
    char4[38] <= 32'h18001E00;
    char4[39] <= 32'h38001E00;
    char4[40] <= 32'h3FFFFFFC;
    char4[41] <= 32'h3FFFFFFC;
    char4[42] <= 32'h00001E00;
    char4[43] <= 32'h00001E00;
    char4[44] <= 32'h00001E00;
    char4[45] <= 32'h00001E00;
    char4[46] <= 32'h00001E00;
    char4[47] <= 32'h00001E00;
    char4[48] <= 32'h00001E00;
    char4[49] <= 32'h00001E00;
    char4[50] <= 32'h00001E00;
    char4[51] <= 32'h00001E00;
    char4[52] <= 32'h00003F00;
    char4[53] <= 32'h000FFFF8;
    char4[54] <= 32'h000FFFF8;
    char4[55] <= 32'h00000000;
    char4[56] <= 32'h00000000;
    char4[57] <= 32'h00000000;
    char4[58] <= 32'h00000000;
    char4[59] <= 32'h00000000;
    char4[60] <= 32'h00000000;
    char4[61] <= 32'h00000000;
    char4[62] <= 32'h00000000;
    char4[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char5[0]  <= 32'h00000000;
    char5[1]  <= 32'h00000000;
    char5[2]  <= 32'h00000000;
    char5[3]  <= 32'h00000000;
    char5[4]  <= 32'h00000000;
    char5[5]  <= 32'h00000000;
    char5[6]  <= 32'h00000000;
    char5[7]  <= 32'h00000000;
    char5[8]  <= 32'h00000000;
    char5[9]  <= 32'h00000000;
    char5[10] <= 32'h00000000;
    char5[11] <= 32'h01FFFFE0;
    char5[12] <= 32'h01FFFFE0;
    char5[13] <= 32'h01FFFFE0;
    char5[14] <= 32'h01FFFFC0;
    char5[15] <= 32'h01800000;
    char5[16] <= 32'h01800000;
    char5[17] <= 32'h01800000;
    char5[18] <= 32'h01800000;
    char5[19] <= 32'h01800000;
    char5[20] <= 32'h01800000;
    char5[21] <= 32'h01800000;
    char5[22] <= 32'h01800000;
    char5[23] <= 32'h01000000;
    char5[24] <= 32'h01000000;
    char5[25] <= 32'h03000000;
    char5[26] <= 32'h0303F800;
    char5[27] <= 32'h031FFE00;
    char5[28] <= 32'h033FFF00;
    char5[29] <= 32'h03781F80;
    char5[30] <= 32'h036007C0;
    char5[31] <= 32'h03C003C0;
    char5[32] <= 32'h038003E0;
    char5[33] <= 32'h038001E0;
    char5[34] <= 32'h000001E0;
    char5[35] <= 32'h000001F0;
    char5[36] <= 32'h000000F0;
    char5[37] <= 32'h000000F0;
    char5[38] <= 32'h000000F0;
    char5[39] <= 32'h000000F0;
    char5[40] <= 32'h000000F0;
    char5[41] <= 32'h000000F0;
    char5[42] <= 32'h038000F0;
    char5[43] <= 32'h07C000F0;
    char5[44] <= 32'h0FC000F0;
    char5[45] <= 32'h0FC000E0;
    char5[46] <= 32'h0FC001E0;
    char5[47] <= 32'h0F8001E0;
    char5[48] <= 32'h0F8001C0;
    char5[49] <= 32'h078003C0;
    char5[50] <= 32'h03800780;
    char5[51] <= 32'h01C00F00;
    char5[52] <= 32'h00F01E00;
    char5[53] <= 32'h007FFC00;
    char5[54] <= 32'h000FE000;
    char5[55] <= 32'h00000000;
    char5[56] <= 32'h00000000;
    char5[57] <= 32'h00000000;
    char5[58] <= 32'h00000000;
    char5[59] <= 32'h00000000;
    char5[60] <= 32'h00000000;
    char5[61] <= 32'h00000000;
    char5[62] <= 32'h00000000;
    char5[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char6[0]  <= 32'h00000000;
    char6[1]  <= 32'h00000000;
    char6[2]  <= 32'h00000000;
    char6[3]  <= 32'h00000000;
    char6[4]  <= 32'h00000000;
    char6[5]  <= 32'h00000000;
    char6[6]  <= 32'h00000000;
    char6[7]  <= 32'h00000000;
    char6[8]  <= 32'h00000000;
    char6[9]  <= 32'h00000000;
    char6[10] <= 32'h00000000;
    char6[11] <= 32'h0001FC00;
    char6[12] <= 32'h0007FF00;
    char6[13] <= 32'h001E0780;
    char6[14] <= 32'h003803C0;
    char6[15] <= 32'h007003E0;
    char6[16] <= 32'h00E003E0;
    char6[17] <= 32'h01C003E0;
    char6[18] <= 32'h038003E0;
    char6[19] <= 32'h038001C0;
    char6[20] <= 32'h07000000;
    char6[21] <= 32'h07000000;
    char6[22] <= 32'h07000000;
    char6[23] <= 32'h0F000000;
    char6[24] <= 32'h0F000000;
    char6[25] <= 32'h0E000000;
    char6[26] <= 32'h0E000000;
    char6[27] <= 32'h0E03F800;
    char6[28] <= 32'h1E0FFF00;
    char6[29] <= 32'h1E3FFF80;
    char6[30] <= 32'h1E7C0FC0;
    char6[31] <= 32'h1EF003E0;
    char6[32] <= 32'h1EE001E0;
    char6[33] <= 32'h1FC001F0;
    char6[34] <= 32'h1F8000F0;
    char6[35] <= 32'h1F0000F0;
    char6[36] <= 32'h1F000078;
    char6[37] <= 32'h1E000078;
    char6[38] <= 32'h1E000078;
    char6[39] <= 32'h1E000078;
    char6[40] <= 32'h1E000078;
    char6[41] <= 32'h1E000078;
    char6[42] <= 32'h0E000078;
    char6[43] <= 32'h0F000078;
    char6[44] <= 32'h0F000078;
    char6[45] <= 32'h0F000070;
    char6[46] <= 32'h070000F0;
    char6[47] <= 32'h078000F0;
    char6[48] <= 32'h03C000E0;
    char6[49] <= 32'h03C001E0;
    char6[50] <= 32'h01E001C0;
    char6[51] <= 32'h00F00380;
    char6[52] <= 32'h007C0F00;
    char6[53] <= 32'h003FFE00;
    char6[54] <= 32'h0007F000;
    char6[55] <= 32'h00000000;
    char6[56] <= 32'h00000000;
    char6[57] <= 32'h00000000;
    char6[58] <= 32'h00000000;
    char6[59] <= 32'h00000000;
    char6[60] <= 32'h00000000;
    char6[61] <= 32'h00000000;
    char6[62] <= 32'h00000000;
    char6[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char7[0]  <= 32'h00000000;
    char7[1]  <= 32'h00000000;
    char7[2]  <= 32'h00000000;
    char7[3]  <= 32'h00000000;
    char7[4]  <= 32'h00000000;
    char7[5]  <= 32'h00000000;
    char7[6]  <= 32'h00000000;
    char7[7]  <= 32'h00000000;
    char7[8]  <= 32'h00000000;
    char7[9]  <= 32'h00000000;
    char7[10] <= 32'h00000000;
    char7[11] <= 32'h03FFFFF0;
    char7[12] <= 32'h07FFFFF0;
    char7[13] <= 32'h07FFFFF0;
    char7[14] <= 32'h07FFFFE0;
    char7[15] <= 32'h07C000C0;
    char7[16] <= 32'h070000C0;
    char7[17] <= 32'h06000180;
    char7[18] <= 32'h06000180;
    char7[19] <= 32'h0C000300;
    char7[20] <= 32'h0C000300;
    char7[21] <= 32'h0C000600;
    char7[22] <= 32'h00000600;
    char7[23] <= 32'h00000C00;
    char7[24] <= 32'h00001C00;
    char7[25] <= 32'h00001800;
    char7[26] <= 32'h00003800;
    char7[27] <= 32'h00003800;
    char7[28] <= 32'h00003000;
    char7[29] <= 32'h00007000;
    char7[30] <= 32'h00007000;
    char7[31] <= 32'h0000E000;
    char7[32] <= 32'h0000E000;
    char7[33] <= 32'h0001E000;
    char7[34] <= 32'h0001C000;
    char7[35] <= 32'h0003C000;
    char7[36] <= 32'h0003C000;
    char7[37] <= 32'h00038000;
    char7[38] <= 32'h00078000;
    char7[39] <= 32'h00078000;
    char7[40] <= 32'h00078000;
    char7[41] <= 32'h000F8000;
    char7[42] <= 32'h000F8000;
    char7[43] <= 32'h000F8000;
    char7[44] <= 32'h000F8000;
    char7[45] <= 32'h000F8000;
    char7[46] <= 32'h001F8000;
    char7[47] <= 32'h001F8000;
    char7[48] <= 32'h001F8000;
    char7[49] <= 32'h001F8000;
    char7[50] <= 32'h001F8000;
    char7[51] <= 32'h001F8000;
    char7[52] <= 32'h001F8000;
    char7[53] <= 32'h001F8000;
    char7[54] <= 32'h000F0000;
    char7[55] <= 32'h00000000;
    char7[56] <= 32'h00000000;
    char7[57] <= 32'h00000000;
    char7[58] <= 32'h00000000;
    char7[59] <= 32'h00000000;
    char7[60] <= 32'h00000000;
    char7[61] <= 32'h00000000;
    char7[62] <= 32'h00000000;
    char7[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char8[0]  <= 32'h00000000;
    char8[1]  <= 32'h00000000;
    char8[2]  <= 32'h00000000;
    char8[3]  <= 32'h00000000;
    char8[4]  <= 32'h00000000;
    char8[5]  <= 32'h00000000;
    char8[6]  <= 32'h00000000;
    char8[7]  <= 32'h00000000;
    char8[8]  <= 32'h00000000;
    char8[9]  <= 32'h00000000;
    char8[10] <= 32'h00000000;
    char8[11] <= 32'h000FF000;
    char8[12] <= 32'h007FFE00;
    char8[13] <= 32'h00F81F00;
    char8[14] <= 32'h01E00780;
    char8[15] <= 32'h03C003C0;
    char8[16] <= 32'h078001E0;
    char8[17] <= 32'h078001E0;
    char8[18] <= 32'h0F0000F0;
    char8[19] <= 32'h0F0000F0;
    char8[20] <= 32'h0F0000F0;
    char8[21] <= 32'h0F0000F0;
    char8[22] <= 32'h0F0000F0;
    char8[23] <= 32'h0F8000F0;
    char8[24] <= 32'h0F8000E0;
    char8[25] <= 32'h07C001E0;
    char8[26] <= 32'h07E001C0;
    char8[27] <= 32'h03F003C0;
    char8[28] <= 32'h01FC0780;
    char8[29] <= 32'h00FF0E00;
    char8[30] <= 32'h007FDC00;
    char8[31] <= 32'h001FF000;
    char8[32] <= 32'h003FF800;
    char8[33] <= 32'h00F1FE00;
    char8[34] <= 32'h01E07F00;
    char8[35] <= 32'h03C03F80;
    char8[36] <= 32'h07801FC0;
    char8[37] <= 32'h078007C0;
    char8[38] <= 32'h0F0003E0;
    char8[39] <= 32'h0F0003E0;
    char8[40] <= 32'h1E0001F0;
    char8[41] <= 32'h1E0001F0;
    char8[42] <= 32'h1E0000F0;
    char8[43] <= 32'h1E0000F0;
    char8[44] <= 32'h1E0000F0;
    char8[45] <= 32'h1E0000F0;
    char8[46] <= 32'h1E0000F0;
    char8[47] <= 32'h0F0000E0;
    char8[48] <= 32'h0F0001E0;
    char8[49] <= 32'h078001C0;
    char8[50] <= 32'h078003C0;
    char8[51] <= 32'h03E00780;
    char8[52] <= 32'h00F81F00;
    char8[53] <= 32'h007FFC00;
    char8[54] <= 32'h000FF000;
    char8[55] <= 32'h00000000;
    char8[56] <= 32'h00000000;
    char8[57] <= 32'h00000000;
    char8[58] <= 32'h00000000;
    char8[59] <= 32'h00000000;
    char8[60] <= 32'h00000000;
    char8[61] <= 32'h00000000;
    char8[62] <= 32'h00000000;
    char8[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char9[0]  <= 32'h00000000;
    char9[1]  <= 32'h00000000;
    char9[2]  <= 32'h00000000;
    char9[3]  <= 32'h00000000;
    char9[4]  <= 32'h00000000;
    char9[5]  <= 32'h00000000;
    char9[6]  <= 32'h00000000;
    char9[7]  <= 32'h00000000;
    char9[8]  <= 32'h00000000;
    char9[9]  <= 32'h00000000;
    char9[10] <= 32'h00000000;
    char9[11] <= 32'h001FE000;
    char9[12] <= 32'h007FF800;
    char9[13] <= 32'h00F03C00;
    char9[14] <= 32'h01E00E00;
    char9[15] <= 32'h03C00700;
    char9[16] <= 32'h07800380;
    char9[17] <= 32'h07000380;
    char9[18] <= 32'h0F0001C0;
    char9[19] <= 32'h0F0001C0;
    char9[20] <= 32'h0E0001E0;
    char9[21] <= 32'h1E0000E0;
    char9[22] <= 32'h1E0000E0;
    char9[23] <= 32'h1E0000E0;
    char9[24] <= 32'h1E0000F0;
    char9[25] <= 32'h1E0000F0;
    char9[26] <= 32'h1E0000F0;
    char9[27] <= 32'h1E0000F0;
    char9[28] <= 32'h1E0000F0;
    char9[29] <= 32'h1E0001F0;
    char9[30] <= 32'h1F0001F0;
    char9[31] <= 32'h0F0003F0;
    char9[32] <= 32'h0F8006F0;
    char9[33] <= 32'h0F800EF0;
    char9[34] <= 32'h07C01CF0;
    char9[35] <= 32'h03F07CF0;
    char9[36] <= 32'h01FFF8F0;
    char9[37] <= 32'h00FFE0F0;
    char9[38] <= 32'h003F81E0;
    char9[39] <= 32'h000001E0;
    char9[40] <= 32'h000001E0;
    char9[41] <= 32'h000001E0;
    char9[42] <= 32'h000001C0;
    char9[43] <= 32'h000003C0;
    char9[44] <= 32'h000003C0;
    char9[45] <= 32'h00000380;
    char9[46] <= 32'h03800780;
    char9[47] <= 32'h07C00700;
    char9[48] <= 32'h07C00F00;
    char9[49] <= 32'h07C00E00;
    char9[50] <= 32'h07C01C00;
    char9[51] <= 32'h03C03800;
    char9[52] <= 32'h03E0F000;
    char9[53] <= 32'h01FFE000;
    char9[54] <= 32'h003F0000;
    char9[55] <= 32'h00000000;
    char9[56] <= 32'h00000000;
    char9[57] <= 32'h00000000;
    char9[58] <= 32'h00000000;
    char9[59] <= 32'h00000000;
    char9[60] <= 32'h00000000;
    char9[61] <= 32'h00000000;
    char9[62] <= 32'h00000000;
    char9[63] <= 32'h00000000;
end
always @(posedge vpg_pclk) begin
    char_score[0]  <= 128'h00000000000000000000000000000000;
    char_score[1]  <= 128'h00000000000000000000000000000000;
    char_score[2]  <= 128'h00000000000000000000000000000000;
    char_score[3]  <= 128'h00002000000000000000000008000000;
    char_score[4]  <= 128'h00003800000000000000010007000000;
    char_score[5]  <= 128'h00007C00000010000000018007000000;
    char_score[6]  <= 128'h00007E0800003800000001E006000000;
    char_score[7]  <= 128'h0000FC0FFFFFFC00000003F006000000;
    char_score[8]  <= 128'h0001F80FFFFFFE00000003F003000000;
    char_score[9]  <= 128'h0001F00E00003C00000007C003000000;
    char_score[10] <= 128'h0003E00E00003800000007C003000000;
    char_score[11] <= 128'h0007800E0000380000000F8003800000;
    char_score[12] <= 128'h000F000E0000380000000F0001800000;
    char_score[13] <= 128'h001E000E0000380000001F0001C00000;
    char_score[14] <= 128'h001C000E0000380000001E0000C00000;
    char_score[15] <= 128'h0038000FFFFFF80000003E0000E00000;
    char_score[16] <= 128'h0070040FFFFFF80000003C0000600000;
    char_score[17] <= 128'h00E00E0E000038000000780000700000;
    char_score[18] <= 128'h01800F0E000038000000780000380000;
    char_score[19] <= 128'h07001FCE000038000000F000003C0000;
    char_score[20] <= 128'h0C001F8E000038000001E000001E0000;
    char_score[21] <= 128'h08003E0E000038000001C000000F0000;
    char_score[22] <= 128'h00007C0E000038000003C000000F8000;
    char_score[23] <= 128'h00007C0E00003800000780000007C000;
    char_score[24] <= 128'h0000F80FFFFFF800000F00000003F000;
    char_score[25] <= 128'h0001F00FFFFFF800000E00000001F800;
    char_score[26] <= 128'h0001E00E00003800001C00000008FE00;
    char_score[27] <= 128'h0003C00E0000300000380000001C7F80;
    char_score[28] <= 128'h00078008000000000073FFFFFFFE3FF8;
    char_score[29] <= 128'h000F80000000030000E1FFFFFFFF1FF0;
    char_score[30] <= 128'h000F80000000078001C0003C001E07C0;
    char_score[31] <= 128'h001F81FFFFFFFFC00300003C001C0380;
    char_score[32] <= 128'h003F80FFFFFFFFE006000078001C0000;
    char_score[33] <= 128'h007780400001C00008000078001C0000;
    char_score[34] <= 128'h00E780000001C00000000078001C0000;
    char_score[35] <= 128'h01C780000001C00000000078003C0000;
    char_score[36] <= 128'h038780000001C00000000070003C0000;
    char_score[37] <= 128'h070780000001C0C0000000F0003C0000;
    char_score[38] <= 128'h0E0780000001C1E0000000F0003C0000;
    char_score[39] <= 128'h18078FFFFFFFFFF0000000F0003C0000;
    char_score[40] <= 128'h100787FFFFFFFFF8000000E0003C0000;
    char_score[41] <= 128'h000782000001C000000001E0003C0000;
    char_score[42] <= 128'h000780080001C000000001E0003C0000;
    char_score[43] <= 128'h000780060001C000000003C0003C0000;
    char_score[44] <= 128'h000780070001C000000003C0003C0000;
    char_score[45] <= 128'h000780038001C00000000380003C0000;
    char_score[46] <= 128'h00078001C001C0000000078000380000;
    char_score[47] <= 128'h00078001E001C0000000070000380000;
    char_score[48] <= 128'h00078000F001C00000000F0000780000;
    char_score[49] <= 128'h00078000F001C00000001E0000780000;
    char_score[50] <= 128'h00078000F001C00000003C0000780000;
    char_score[51] <= 128'h000780007001C0000000380000780000;
    char_score[52] <= 128'h000780007001C0000000700000780000;
    char_score[53] <= 128'h000780002001C0000000E00000F00000;
    char_score[54] <= 128'h000780000001C0000001C00381F00000;
    char_score[55] <= 128'h000780000603C00000078001FFE00000;
    char_score[56] <= 128'h0007800003FFC000000E00007FE00000;
    char_score[57] <= 128'h0007800000FFC000003800001FC00000;
    char_score[58] <= 128'h00078000003F8000007000000F800000;
    char_score[59] <= 128'h00078000000F800001C000000E000000;
    char_score[60] <= 128'h00070000000E00000300000000000000;
    char_score[61] <= 128'h00040000000400000000000000000000;
    char_score[62] <= 128'h00000000000000000000000000000000;
    char_score[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_mode[0]  <= 128'h00000000000000000000000000000000;
    char_mode[1]  <= 128'h00000000000000000000000000000000;
    char_mode[2]  <= 128'h00000000000400000000000000000000;
    char_mode[3]  <= 128'h00070000700700000000000010000000;
    char_mode[4]  <= 128'h0007C0007C07C000000000001C000000;
    char_mode[5]  <= 128'h0007C00078078000000000001F000000;
    char_mode[6]  <= 128'h0007000070070000000000001F0E0000;
    char_mode[7]  <= 128'h0007000070070000000000001E078000;
    char_mode[8]  <= 128'h0007000070070180000000001E03E000;
    char_mode[9]  <= 128'h00070000700703C0000000001E01F000;
    char_mode[10] <= 128'h000703FFFFFFFFE0000000001E00F800;
    char_mode[11] <= 128'h000701FFFFFFFFF0000000001E00F800;
    char_mode[12] <= 128'h0007008070070000000000001E007800;
    char_mode[13] <= 128'h0007000070070000000000001E007A00;
    char_mode[14] <= 128'h0007000070070000000000001E003700;
    char_mode[15] <= 128'h0007060070070000000000001E000F80;
    char_mode[16] <= 128'h00070F0070070000000000001E001FC0;
    char_mode[17] <= 128'h3FFFFF806004000007FFFFFFFFFFFFE0;
    char_mode[18] <= 128'h1FFFFFC00000000003FFFFFFFFFFFFF0;
    char_mode[19] <= 128'h080F000C00001800018000000E000000;
    char_mode[20] <= 128'h000F000FFFFFFE00000000000E000000;
    char_mode[21] <= 128'h000F000FFFFFFE00000000000E000000;
    char_mode[22] <= 128'h000F000F00003C00000000000E000000;
    char_mode[23] <= 128'h000F000F00003C00000000000E000000;
    char_mode[24] <= 128'h001F000F00003C00000000000F000000;
    char_mode[25] <= 128'h001F800F00003C00000000000F000000;
    char_mode[26] <= 128'h001FE00F00003C00000000040F000000;
    char_mode[27] <= 128'h001F700FFFFFFC000000000E0F000000;
    char_mode[28] <= 128'h003F3C0FFFFFFC000000001F0F000000;
    char_mode[29] <= 128'h003F1E0F00003C0003FFFFFF87000000;
    char_mode[30] <= 128'h003F1F0F00003C0001FFFFFFC7000000;
    char_mode[31] <= 128'h00770F0F00003C0000803C0007800000;
    char_mode[32] <= 128'h0077078F00003C0000003C0007800000;
    char_mode[33] <= 128'h00E7078F00003C0000003C0007800000;
    char_mode[34] <= 128'h00E7070F00003C0000003C0007800000;
    char_mode[35] <= 128'h00C7030FFFFFFC0000003C0003800000;
    char_mode[36] <= 128'h01C7000FFFFFFC0000003C0003C00000;
    char_mode[37] <= 128'h0187000F03803C0000003C0003C00000;
    char_mode[38] <= 128'h0387000F03803C0000003C0003C00000;
    char_mode[39] <= 128'h0307000E0380200000003C0001E00000;
    char_mode[40] <= 128'h060700000380000000003C0001E00000;
    char_mode[41] <= 128'h060700000380008000003C0001F00000;
    char_mode[42] <= 128'h0C070000038001C000003C0000F00000;
    char_mode[43] <= 128'h08070000078003E000003C0000F00020;
    char_mode[44] <= 128'h10070FFFFFFFFFF000003C0000780020;
    char_mode[45] <= 128'h200707FFFFFFFFF800003C0000780060;
    char_mode[46] <= 128'h000703000720000000003C00383C0060;
    char_mode[47] <= 128'h000700000F30000000003C03E03E0060;
    char_mode[48] <= 128'h000700000F18000000003C7F001E0060;
    char_mode[49] <= 128'h000700001E1C000000003FF8001F0060;
    char_mode[50] <= 128'h000700001E0E000000007FC0000F8060;
    char_mode[51] <= 128'h000700003C0700000007FE000007C0E0;
    char_mode[52] <= 128'h000700007807800000FFF0000007F0E0;
    char_mode[53] <= 128'h000700007803C0000FFF80000003F8E0;
    char_mode[54] <= 128'h00070000F001F00007FC00000001FEE0;
    char_mode[55] <= 128'h00070001E000FC0007E000000000FFE0;
    char_mode[56] <= 128'h0007000380007FC00380000000003FF0;
    char_mode[57] <= 128'h0007000F00003FF80100000000001FF0;
    char_mode[58] <= 128'h0007003C00001FE000000000000007F0;
    char_mode[59] <= 128'h000700F00000078000000000000001F8;
    char_mode[60] <= 128'h000707C0000001800000000000000038;
    char_mode[61] <= 128'h00001C00000000000000000000000000;
    char_mode[62] <= 128'h00000000000000000000000000000000;
    char_mode[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_mode1[0]  <= 128'h00000000000000000000000000000000;
    char_mode1[1]  <= 128'h00000000000000000000000000000000;
    char_mode1[2]  <= 128'h00000000000000000000000000400000;
    char_mode1[3]  <= 128'h00000000020000000000300000600000;
    char_mode1[4]  <= 128'h000380000300000000001C0000780000;
    char_mode1[5]  <= 128'h0003C0000780000000000E0000FC0000;
    char_mode1[6]  <= 128'h0007E00007E000000000078000F80000;
    char_mode1[7]  <= 128'h0007C0000F800000000007C001F00000;
    char_mode1[8]  <= 128'h000F80080F000300000003E001E00000;
    char_mode1[9]  <= 128'h000F001C1E000780000003E001C00000;
    char_mode1[10] <= 128'h001FFFFE1FFFFFC0000001E003800000;
    char_mode1[11] <= 128'h001FFFFFBFFFFFE0000001E003000000;
    char_mode1[12] <= 128'h0038300078300000000000E006000000;
    char_mode1[13] <= 128'h00701C00701C0000000800C00C000000;
    char_mode1[14] <= 128'h00600E00E00E0000000C00000C00C000;
    char_mode1[15] <= 128'h00C00F01C00F0000000FFFFFFFFFF000;
    char_mode1[16] <= 128'h01C00F01800F0000000FFFFFFFFFF000;
    char_mode1[17] <= 128'h0380070300070000000F00078001E000;
    char_mode1[18] <= 128'h0303070600060000000F00078001E000;
    char_mode1[19] <= 128'h0403800400000000000F00078001E000;
    char_mode1[20] <= 128'h0801E00000000C00000F00078001E000;
    char_mode1[21] <= 128'h0000F07FFFFFFE00000F00078001E000;
    char_mode1[22] <= 128'h0000783FFFFFFF00000F00078001E000;
    char_mode1[23] <= 128'h00407C1000001E00000F00078001E000;
    char_mode1[24] <= 128'h00303C0000001C00000FFFFFFFFFE000;
    char_mode1[25] <= 128'h003C3C0000001C00000FFFFFFFFFE000;
    char_mode1[26] <= 128'h003C380000001C00000F00078001E000;
    char_mode1[27] <= 128'h0038100000001C00000F00078001E000;
    char_mode1[28] <= 128'h0038000002001C00000F00078001E000;
    char_mode1[29] <= 128'h0038018003001C00000F00078001E000;
    char_mode1[30] <= 128'h003801FFFF801C00000F00078001E000;
    char_mode1[31] <= 128'h003801FFFFC01C00000F00078001E000;
    char_mode1[32] <= 128'h003801E007801C00000F00078001E000;
    char_mode1[33] <= 128'h003801E007001C00000F00078001E000;
    char_mode1[34] <= 128'h003801E007001C00000FFFFFFFFFE000;
    char_mode1[35] <= 128'h003801E007001C00000FFFFFFFFFE000;
    char_mode1[36] <= 128'h003801E007001C00000F00078001E000;
    char_mode1[37] <= 128'h003801E007001C00000F00078001C000;
    char_mode1[38] <= 128'h003801E007001C00000F000780010000;
    char_mode1[39] <= 128'h003801FFFF001C00000E000780000000;
    char_mode1[40] <= 128'h003801FFFF001C000000000780000000;
    char_mode1[41] <= 128'h003801E007001C000000000780000180;
    char_mode1[42] <= 128'h003801E007001C0000000007800003C0;
    char_mode1[43] <= 128'h003801E007001C0000000007800007E0;
    char_mode1[44] <= 128'h003801E007001C001FFFFFFFFFFFFFF0;
    char_mode1[45] <= 128'h003801E007001C000FFFFFFFFFFFFFF8;
    char_mode1[46] <= 128'h003801E007001C000000000780000000;
    char_mode1[47] <= 128'h003801E007001C000000000780000000;
    char_mode1[48] <= 128'h003801FFFF001C000000000780000000;
    char_mode1[49] <= 128'h003801FFFF001C000000000780000000;
    char_mode1[50] <= 128'h003801E007001C000000000780000000;
    char_mode1[51] <= 128'h003801E006001C000000000780000000;
    char_mode1[52] <= 128'h003801E000001C000000000780000000;
    char_mode1[53] <= 128'h0038010000001C000000000780000000;
    char_mode1[54] <= 128'h0038000000001C000000000780000000;
    char_mode1[55] <= 128'h00380000007C3C000000000780000000;
    char_mode1[56] <= 128'h00380000001FFC000000000780000000;
    char_mode1[57] <= 128'h003800000003FC000000000780000000;
    char_mode1[58] <= 128'h003800000001FC000000000780000000;
    char_mode1[59] <= 128'h00380000000078000000000780000000;
    char_mode1[60] <= 128'h00380000000060000000000400000000;
    char_mode1[61] <= 128'h00200000000000000000000000000000;
    char_mode1[62] <= 128'h00000000000000000000000000000000;
    char_mode1[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_mode2[0]  <= 128'h00000000000000000000000000000000;
    char_mode2[1]  <= 128'h00000000000000000000000000000000;
    char_mode2[2]  <= 128'h00000000000000000000000004000000;
    char_mode2[3]  <= 128'h00000001000800000000000007000000;
    char_mode2[4]  <= 128'h00000001C00E0000000000000F800000;
    char_mode2[5]  <= 128'h00400001F00F8000040008000F800000;
    char_mode2[6]  <= 128'h00300001F00F800006001C000F000000;
    char_mode2[7]  <= 128'h003C0001E00F000007FFFE001F800000;
    char_mode2[8]  <= 128'h001E0001C00F000007FFFF001E800000;
    char_mode2[9]  <= 128'h000F0001C00F000007803E003CC00000;
    char_mode2[10] <= 128'h000F8001C00F000007803C003C600000;
    char_mode2[11] <= 128'h00078001C00F00000780780078600000;
    char_mode2[12] <= 128'h0007C001C00F00000780780070300000;
    char_mode2[13] <= 128'h00078001C00F020007807000F0380000;
    char_mode2[14] <= 128'h00038001C00F060007807000E01C0000;
    char_mode2[15] <= 128'h00030001C00F0F000780E001C01C0000;
    char_mode2[16] <= 128'h00000FFFFFFFFF800780E003C00E0000;
    char_mode2[17] <= 128'h000007FFFFFFFFC00780C00780070000;
    char_mode2[18] <= 128'h00000301C00F00000781C0070007C000;
    char_mode2[19] <= 128'h00000001C00F00000781800E0003E000;
    char_mode2[20] <= 128'h00000001C00F00000781801C0001F800;
    char_mode2[21] <= 128'h00000001C00F0000078300380000FE00;
    char_mode2[22] <= 128'h00000001C00F00000783007000007F80;
    char_mode2[23] <= 128'h00020001C00F0000078200E000001FF0;
    char_mode2[24] <= 128'h00070001C00F0000078601C000080FF8;
    char_mode2[25] <= 128'h3FFF8001C00F000007830301000E07E0;
    char_mode2[26] <= 128'h1FFFC001C00F000007818601C00F01C0;
    char_mode2[27] <= 128'h080F0001C00F00000780C801F00F8000;
    char_mode2[28] <= 128'h000F0001C00F000007804001C00F0000;
    char_mode2[29] <= 128'h000F0001C00F000007806001C00F0000;
    char_mode2[30] <= 128'h000F0001C00F018007803001C00F0000;
    char_mode2[31] <= 128'h000F0001C00F03C007803801C00F0000;
    char_mode2[32] <= 128'h000F1FFFFFFFFFE007803801C00F0000;
    char_mode2[33] <= 128'h000F0FFFFFFFFFF007801C01C00F0000;
    char_mode2[34] <= 128'h000F0401C00F000007801C01C00F0000;
    char_mode2[35] <= 128'h000F0001C00F000007801C01C00F0000;
    char_mode2[36] <= 128'h000F0001C00F000007801E01C00F0000;
    char_mode2[37] <= 128'h000F0001C00F000007801E01C00F0000;
    char_mode2[38] <= 128'h000F0003800F000007801E01C00F0000;
    char_mode2[39] <= 128'h000F0003800F000007801E01C00F0000;
    char_mode2[40] <= 128'h000F0003800F000007803C03C00F0000;
    char_mode2[41] <= 128'h000F0007000F000007F87C03C00F0000;
    char_mode2[42] <= 128'h000F0007000F000007FFFC03C00F0000;
    char_mode2[43] <= 128'h000F000E000F0000079FF803800F0000;
    char_mode2[44] <= 128'h000F000E000F00000787F003800F0000;
    char_mode2[45] <= 128'h000F001C000F00000783E003800F0000;
    char_mode2[46] <= 128'h000F0038000F000007838003800F0000;
    char_mode2[47] <= 128'h000F0070000F000007800007800F0000;
    char_mode2[48] <= 128'h000F00E0000F000007800007000F0000;
    char_mode2[49] <= 128'h001F81C0000F000007800007000F0000;
    char_mode2[50] <= 128'h0039C300000F00000780000E000F0000;
    char_mode2[51] <= 128'h0070E400000F00000780000E000F0000;
    char_mode2[52] <= 128'h01E03800000E00000780001C000F0000;
    char_mode2[53] <= 128'h03C01E000008000007800018000F0000;
    char_mode2[54] <= 128'h07800F800000000007800038000F0000;
    char_mode2[55] <= 128'h0F8007FC0000007C07800070000F0000;
    char_mode2[56] <= 128'h1F0001FFFFFFFFF0078000C0000F0000;
    char_mode2[57] <= 128'h0E00007FFFFFFFC007800180000F0000;
    char_mode2[58] <= 128'h0600001FFFFFFF8007800700000E0000;
    char_mode2[59] <= 128'h000000003FFFFF0007000C0000080000;
    char_mode2[60] <= 128'h00000000000000000400100000000000;
    char_mode2[61] <= 128'h00000000000000000000000000000000;
    char_mode2[62] <= 128'h00000000000000000000000000000000;
    char_mode2[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_mode3[0]  <= 128'h00000000000000000000000000000000;
    char_mode3[1]  <= 128'h00000000000000000000000000000000;
    char_mode3[2]  <= 128'h00000000000000000000000000000000;
    char_mode3[3]  <= 128'h00000000000000000000000000400000;
    char_mode3[4]  <= 128'h00000000000004000000000018300000;
    char_mode3[5]  <= 128'h00C0000000000E00000000003E380000;
    char_mode3[6]  <= 128'h00FFFFFFFFFFFF00000000003F1C0000;
    char_mode3[7]  <= 128'h00FFFFFFFFFFFF80000000003E1F0000;
    char_mode3[8]  <= 128'h00F0000000000F00000000003C0F0000;
    char_mode3[9]  <= 128'h00F0000300000F0000000000780F0000;
    char_mode3[10] <= 128'h00F00003C0000F000000000078070000;
    char_mode3[11] <= 128'h00F00003F0000F000000010078070000;
    char_mode3[12] <= 128'h00F00003E0000F00000001C070070000;
    char_mode3[13] <= 128'h00F00003C0000F0007FFFFE0F0060300;
    char_mode3[14] <= 128'h00F00003C0000F0003FFFFF0E0000780;
    char_mode3[15] <= 128'h00F00003C0000F00010003E0FFFFFFC0;
    char_mode3[16] <= 128'h00F00003C0000F00000003C1FFFFFFE0;
    char_mode3[17] <= 128'h00F00003C0000F0000000381E01E0000;
    char_mode3[18] <= 128'h00F00003C0040F0000000781E01E0000;
    char_mode3[19] <= 128'h00F00003C00E0F0000000783E01E0000;
    char_mode3[20] <= 128'h00F00003C01F0F0000000783E01E0000;
    char_mode3[21] <= 128'h00F3FFFFFFFF8F0003000703E01E0000;
    char_mode3[22] <= 128'h00F1FFFFFFFFCF0001800F07E01E0000;
    char_mode3[23] <= 128'h00F0800FC0000F0000800F07E01E0000;
    char_mode3[24] <= 128'h00F0001FC0000F0000C00E0FE01E0000;
    char_mode3[25] <= 128'h00F0001FC0000F0000600E0FE01E0000;
    char_mode3[26] <= 128'h00F0003FC0000F0000301E1DE01E0600;
    char_mode3[27] <= 128'h00F0003FC0000F0000181C19E01E0F00;
    char_mode3[28] <= 128'h00F0003BC0000F00001C1C39FFFFFF80;
    char_mode3[29] <= 128'h00F0007BE0000F00000E3C31FFFFFFC0;
    char_mode3[30] <= 128'h00F00073F8000F0000073861E01E0000;
    char_mode3[31] <= 128'h00F000F3DE000F0000073841E01E0000;
    char_mode3[32] <= 128'h00F001E3C7800F000003F8C1E01E0000;
    char_mode3[33] <= 128'h00F001C3C3E00F000001F181E01E0000;
    char_mode3[34] <= 128'h00F003C3C1F80F000000F001E01E0000;
    char_mode3[35] <= 128'h00F00383C0FC0F000000F001E01E0000;
    char_mode3[36] <= 128'h00F00703C07E0F000001F001E01E0000;
    char_mode3[37] <= 128'h00F00F03C03E0F000001F801E01E0200;
    char_mode3[38] <= 128'h00F00E03C01F0F000003FC01E01E0700;
    char_mode3[39] <= 128'h00F01C03C01F0F0000039E01E01E0F80;
    char_mode3[40] <= 128'h00F03803C00F0F0000079E01FFFFFFC0;
    char_mode3[41] <= 128'h00F07003C0070F0000070F01FFFFFFE0;
    char_mode3[42] <= 128'h00F0E003C0060F00000E0F01E01E0000;
    char_mode3[43] <= 128'h00F0C003C0020F00001C0781E01E0000;
    char_mode3[44] <= 128'h00F18003C0000F00001C0781E01E0000;
    char_mode3[45] <= 128'h00F20003C0000F0000380381E01E0000;
    char_mode3[46] <= 128'h00FC0003C0000F00007003C1E01E0000;
    char_mode3[47] <= 128'h00F00003C0000F00006003C1E01E0000;
    char_mode3[48] <= 128'h00F00003C0000F0000C003C1E01E0000;
    char_mode3[49] <= 128'h00F00003C0000F0001C00181E01E0000;
    char_mode3[50] <= 128'h00F00003C0000F0003800181E01E0000;
    char_mode3[51] <= 128'h00F00003C0000F0007000001E01E0000;
    char_mode3[52] <= 128'h00F0000300000F0006000001E01E00C0;
    char_mode3[53] <= 128'h00F0000000000F0008000001E01E01E0;
    char_mode3[54] <= 128'h00F0000000000F0010000001FFFFFFF0;
    char_mode3[55] <= 128'h00FFFFFFFFFFFF0000000001FFFFFFF8;
    char_mode3[56] <= 128'h00FFFFFFFFFFFF0000000001E0000000;
    char_mode3[57] <= 128'h00F0000000000F0000000001E0000000;
    char_mode3[58] <= 128'h00F0000000000F0000000001E0000000;
    char_mode3[59] <= 128'h00F0000000000C0000000001E0000000;
    char_mode3[60] <= 128'h00C00000000000000000000100000000;
    char_mode3[61] <= 128'h00000000000000000000000000000000;
    char_mode3[62] <= 128'h00000000000000000000000000000000;
    char_mode3[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_mode4[0]  <= 128'h00000000000000000000000000000000;
    char_mode4[1]  <= 128'h00000000000000000000000000000000;
    char_mode4[2]  <= 128'h00000000020000000000000000000000;
    char_mode4[3]  <= 128'h00018000038000000000000000000000;
    char_mode4[4]  <= 128'h0001E00003E000000000000000000400;
    char_mode4[5]  <= 128'h0001F00003C0000000C0000000000E00;
    char_mode4[6]  <= 128'h0001E00003C0000000FFFFFFFFFFFF00;
    char_mode4[7]  <= 128'h0001E00003C0000000FFFFFFFFFFFF80;
    char_mode4[8]  <= 128'h0001E00003C0000000F0000000000F00;
    char_mode4[9]  <= 128'h0001E00003C0000000F0000300000F00;
    char_mode4[10] <= 128'h0201E00003C0180000F00003C0000F00;
    char_mode4[11] <= 128'h03C1E00003C03C0000F00003F0000F00;
    char_mode4[12] <= 128'h03F1E03FFFFFFE0000F00003E0000F00;
    char_mode4[13] <= 128'h03E1E01FFFFFFF0000F00003C0000F00;
    char_mode4[14] <= 128'h03C1E00803C0000000F00003C0000F00;
    char_mode4[15] <= 128'h03C1E00003C0000000F00003C0000F00;
    char_mode4[16] <= 128'h03C1E00003C0000000F00003C0000F00;
    char_mode4[17] <= 128'h0381E08003C0000000F00003C0000F00;
    char_mode4[18] <= 128'h0381E18003C0000000F00003C0040F00;
    char_mode4[19] <= 128'h0781E3C003C0000000F00003C00E0F00;
    char_mode4[20] <= 128'h07FFFFE003C0000000F00003C01F0F00;
    char_mode4[21] <= 128'h07FFFFF003C0008000F3FFFFFFFF8F00;
    char_mode4[22] <= 128'h0701E00003C001C000F1FFFFFFFFCF00;
    char_mode4[23] <= 128'h0601E00003C003E000F0800FC0000F00;
    char_mode4[24] <= 128'h0E01E1FFFFFFFFF000F0001FC0000F00;
    char_mode4[25] <= 128'h0E01E0FFFFFFFFF800F0001FC0000F00;
    char_mode4[26] <= 128'h0C01E0400000000000F0003FC0000F00;
    char_mode4[27] <= 128'h0C01E0000002000000F0003FC0000F00;
    char_mode4[28] <= 128'h1801E0000003800000F0003BC0000F00;
    char_mode4[29] <= 128'h1801E0000003E00000F0007BE0000F00;
    char_mode4[30] <= 128'h1001E0100003C00000F00073F8000F00;
    char_mode4[31] <= 128'h3001E0600003800000F000F3DE000F00;
    char_mode4[32] <= 128'h0001E1C00003800000F001E3C7800F00;
    char_mode4[33] <= 128'h0001EF00000380C000F001C3C3E00F00;
    char_mode4[34] <= 128'h0001FC00000381E000F003C3C1F80F00;
    char_mode4[35] <= 128'h0001F8FFFFFFFFF000F00383C0FC0F00;
    char_mode4[36] <= 128'h0003E07FFFFFFFF800F00703C07E0F00;
    char_mode4[37] <= 128'h001FE0200003800000F00F03C03E0F00;
    char_mode4[38] <= 128'h007FE0000003800000F00E03C01F0F00;
    char_mode4[39] <= 128'h03FDE0000003800000F01C03C01F0F00;
    char_mode4[40] <= 128'h1FF1E00C0003800000F03803C00F0F00;
    char_mode4[41] <= 128'h0FC1E0060003800000F07003C0070F00;
    char_mode4[42] <= 128'h0F81E0078003800000F0E003C0060F00;
    char_mode4[43] <= 128'h0701E003C003800000F0C003C0020F00;
    char_mode4[44] <= 128'h0201E003E003800000F18003C0000F00;
    char_mode4[45] <= 128'h0001E001E003800000F20003C0000F00;
    char_mode4[46] <= 128'h0001E001F003800000FC0003C0000F00;
    char_mode4[47] <= 128'h0001E000F003800000F00003C0000F00;
    char_mode4[48] <= 128'h0001E000F003800000F00003C0000F00;
    char_mode4[49] <= 128'h0001E000F003800000F00003C0000F00;
    char_mode4[50] <= 128'h0001E000E003800000F00003C0000F00;
    char_mode4[51] <= 128'h0001E0004003800000F00003C0000F00;
    char_mode4[52] <= 128'h0001E0000003800000F0000300000F00;
    char_mode4[53] <= 128'h0001E0000003800000F0000000000F00;
    char_mode4[54] <= 128'h0001E0000003800000F0000000000F00;
    char_mode4[55] <= 128'h0001E0001FFF800000FFFFFFFFFFFF00;
    char_mode4[56] <= 128'h0001E00007FF800000FFFFFFFFFFFF00;
    char_mode4[57] <= 128'h0001E00000FF800000F0000000000F00;
    char_mode4[58] <= 128'h0001E000007F000000F0000000000F00;
    char_mode4[59] <= 128'h0001E000003E000000F0000000000C00;
    char_mode4[60] <= 128'h0001E000001C000000C0000000000000;
    char_mode4[61] <= 128'h00010000000000000000000000000000;
    char_mode4[62] <= 128'h00000000000000000000000000000000;
    char_mode4[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_game[0]  <= 128'h00000000000000000000000000000000;
    char_game[1]  <= 128'h00000000000000000000000000000000;
    char_game[2]  <= 128'h00000000000000000000000000000000;
    char_game[3]  <= 128'h00000000001000000000000040000000;
    char_game[4]  <= 128'h00000000001C00000000000078000000;
    char_game[5]  <= 128'h00C00300001F0000000000007E000000;
    char_game[6]  <= 128'h00700180003E0000000000007E000000;
    char_game[7]  <= 128'h007C01E0003C0000000000007C000000;
    char_game[8]  <= 128'h003E00F000380000000000007C1C0000;
    char_game[9]  <= 128'h001F007800780000000000003C0F8000;
    char_game[10] <= 128'h001F007C00700000000000003C07E000;
    char_game[11] <= 128'h000F003C00700080000000003C03F000;
    char_game[12] <= 128'h000F003800E00180000000003C01F800;
    char_game[13] <= 128'h0006003800E003C0000001803C00FC00;
    char_game[14] <= 128'h0000000001FFFFE0000003C03C007C00;
    char_game[15] <= 128'h0000000081FFFFF00FFFFFE03C003800;
    char_game[16] <= 128'h00002001C180000007FFFFE03C003800;
    char_game[17] <= 128'h00007FFFE3000000020007C01C001000;
    char_game[18] <= 128'h10005FFFF3000000000007801C000180;
    char_game[19] <= 128'h1C004DC006000000000007801E0001C0;
    char_game[20] <= 128'h0F00C1C00C000100000007801E0003E0;
    char_game[21] <= 128'h078081C008000380000007801E000FF0;
    char_game[22] <= 128'h07C081C013FFFFC000000F001E1FFFC0;
    char_game[23] <= 128'h03E181C011FFFFE000000F003FFF0000;
    char_game[24] <= 128'h03E181C000C007C002000FFFFE000000;
    char_game[25] <= 128'h01E101C000000F0003000E7C0E000000;
    char_game[26] <= 128'h01E301C060001C0001801E200F000000;
    char_game[27] <= 128'h00C301FFF000380000E01E000F000800;
    char_game[28] <= 128'h008301FFF800600000701E000F001C00;
    char_game[29] <= 128'h000201C0F002400000381C000F001E00;
    char_game[30] <= 128'h000601C0E0038000001C3C000F003F00;
    char_game[31] <= 128'h000601C0E003E000000E3C0007003E00;
    char_game[32] <= 128'h000603C0E003C0000007380007807C00;
    char_game[33] <= 128'h000C03C0E003C0000007F8000780F800;
    char_game[34] <= 128'h000C0380E003C0000003F8000780F000;
    char_game[35] <= 128'h000C0380E003C0C00001F0000381F000;
    char_game[36] <= 128'h001C0380E003C1E00000F0000383E000;
    char_game[37] <= 128'h00180380EFFFFFE00001F80003C7C000;
    char_game[38] <= 128'h00380380E7FFFFF00001FC0003C78000;
    char_game[39] <= 128'h00380700E203C0000003FE0001CF8000;
    char_game[40] <= 128'h00780700E003C00000039F0001FF0000;
    char_game[41] <= 128'h1FF00701C003C00000039F0001FE0000;
    char_game[42] <= 128'h07F00701C003C00000070F8000FC0020;
    char_game[43] <= 128'h01F00E01C003C000000F07C000F80020;
    char_game[44] <= 128'h00F00E01C003C000000E07C001F00020;
    char_game[45] <= 128'h00F00E01C003C000001C03E003F80020;
    char_game[46] <= 128'h00F01C01C003C000001C03E007FC0020;
    char_game[47] <= 128'h00F01C01C003C000003801E00FBE0060;
    char_game[48] <= 128'h00F03801C003C000003001E01F1E0060;
    char_game[49] <= 128'h01F03803C003C000007000C03C0F0060;
    char_game[50] <= 128'h01E070038003C00000E000C0780F8060;
    char_game[51] <= 128'h01E070038003C00000C00000F007C0E0;
    char_game[52] <= 128'h01E0E0038003C00001800003C003F0E0;
    char_game[53] <= 128'h01E0C0078003C000038000078001F8E0;
    char_game[54] <= 128'h01E183FF8003C0000700000E0000FEE0;
    char_game[55] <= 128'h00E380FF01FFC0000600003800007FE0;
    char_game[56] <= 128'h0063007E007FC0000C00007000003FE0;
    char_game[57] <= 128'h0006003E001F8000180001C000001FE0;
    char_game[58] <= 128'h000C0038000F800030000700000007F0;
    char_game[59] <= 128'h001800000007000000000400000001F0;
    char_game[60] <= 128'h00100000000000000000000000000038;
    char_game[61] <= 128'h00000000000000000000000000000000;
    char_game[62] <= 128'h00000000000000000000000000000000;
    char_game[63] <= 128'h00000000000000000000000000000000;
end
always @(posedge vpg_pclk) begin
    char_snake[0]  <= 192'h000000000000000000000000000000000000000000000000;
    char_snake[1]  <= 192'h000000000000000000000000000000000000000000000000;
    char_snake[2]  <= 192'h000000040000000000000000000000000000000000000000;
    char_snake[3]  <= 192'h000000070000000000000000100000000002000000000000;
    char_snake[4]  <= 192'h0000000F80000000000000001C0000000003800000C00000;
    char_snake[5]  <= 192'h0000001FC0000000000000001E0000000003E00000600000;
    char_snake[6]  <= 192'h0000001F00000000000000003F0000000003C00000780000;
    char_snake[7]  <= 192'h0000003F80000000000000003E00000000038000003C0000;
    char_snake[8]  <= 192'h0000007CC0000000000000003C00000000038000003E0000;
    char_snake[9]  <= 192'h0000007860000000000000007C00000000038000001E0000;
    char_snake[10] <= 192'h000000F070000000000000007800000000038000001E0000;
    char_snake[11] <= 192'h000001F038000000040004007000000000038001801E0000;
    char_snake[12] <= 192'h000003E01C00000003000E00F000000000038001801C00C0;
    char_snake[13] <= 192'h000007C80F00000003FFFF00E000000000038001800800E0;
    char_snake[14] <= 192'h00000F8E0780000003FFFF01E000030000038001FFFFFFF0;
    char_snake[15] <= 192'h00001E0701E0000003801E01C000078000038001FFFFFFF8;
    char_snake[16] <= 192'h00003C0380FC000003801E03FFFFFFC000038003800001F0;
    char_snake[17] <= 192'h00007803C07F000003801E03FFFFFFE006038183800001C0;
    char_snake[18] <= 192'h0001E003C01FF00003801E078000000007FFFFE780000380;
    char_snake[19] <= 192'h0003C001C007FFF803801E070000000007FFFFE780000300;
    char_snake[20] <= 192'h000F00018001FFF003801E0E00000000070383CF80000600;
    char_snake[21] <= 192'h001E000100607FC003801E0E00000000070383CF00000600;
    char_snake[22] <= 192'h007BFFFFFFF00F8003801E1C00000000070383DE10000400;
    char_snake[23] <= 192'h01E1FFFFFFF8018003801E1800000000070383C01C000000;
    char_snake[24] <= 192'h0700800001F8000003801E3000000000070383C01F000000;
    char_snake[25] <= 192'h1C00000001E0000003801E6000018000070383C01F000000;
    char_snake[26] <= 192'h0000000003C0000003801E400003C000070383C01E000000;
    char_snake[27] <= 192'h000000000780000003801EFFFFFFE000070383C01C000000;
    char_snake[28] <= 192'h000000000F00000003801F9FFFFFF000070383C01C000400;
    char_snake[29] <= 192'h000000001E00000003801E080007C000070383C01C000E00;
    char_snake[30] <= 192'h000000003C00000003801E00000F8000070383C01C001F00;
    char_snake[31] <= 192'h000000003C00000003801E00001F0000070383C01C003F80;
    char_snake[32] <= 192'h000300007807000003801E00003E0000070383C01C007E00;
    char_snake[33] <= 192'h0003FFFFFFFF800003801E00003C0000070383C01C00F800;
    char_snake[34] <= 192'h0003FFFFFFFF800003801E0000780000070383C01C01F000;
    char_snake[35] <= 192'h0003C000000F000003801E0000F00000070383C01C03C000;
    char_snake[36] <= 192'h0003C000000F000003801E0001E00000070383C01C0F0000;
    char_snake[37] <= 192'h0003C004000F000003801E0003E0000007FFFFC01C1E0000;
    char_snake[38] <= 192'h0003C007000F000003FFFE0007C0000007FFFFC01C780000;
    char_snake[39] <= 192'h0003C007C00F000003FFFE000F800000070383C01CE00000;
    char_snake[40] <= 192'h0003C007E00F000003801E000F000000070383001F800000;
    char_snake[41] <= 192'h0003C007800F000003801E001E000000060380001E000000;
    char_snake[42] <= 192'h0003C007800F000003801E003C000180000380001C000000;
    char_snake[43] <= 192'h0003C007000F000003801E0078000180000384001C0000C0;
    char_snake[44] <= 192'h0003C007000F000003801800F8000180000386001C0000C0;
    char_snake[45] <= 192'h0003C00F000F000003800000F0000180000383001C0000C0;
    char_snake[46] <= 192'h0003C00F000F000003000001E0000180000383801C0000C0;
    char_snake[47] <= 192'h0003C00E000F000004000003C0000180000381C01C0000C0;
    char_snake[48] <= 192'h0003C01E000F00000000000780000180000381E01C0000C0;
    char_snake[49] <= 192'h0003C01E000E00000000000780000180000381F01C0000C0;
    char_snake[50] <= 192'h0003C03C000000000000000F000001800003BFF01C0000C0;
    char_snake[51] <= 192'h0003003C000000000000000F00000180000FF8F01C0000C0;
    char_snake[52] <= 192'h000000783F8000000000000F000001C003FF80701C0000C0;
    char_snake[53] <= 192'h000000F003FE00000000000F000003E01FFC00701C0000E0;
    char_snake[54] <= 192'h000001E0007FE0000000000F000003F01FE000701C0001E0;
    char_snake[55] <= 192'h000007C0000FF8000000000F800007F00F0000201E0003F0;
    char_snake[56] <= 192'h00001F000003FE0000000007FFFFFFE00C0000001FFFFFF0;
    char_snake[57] <= 192'h00007E000000FF0000000003FFFFFFE0000000000FFFFFF0;
    char_snake[58] <= 192'h0001F00000003F0000000000FFFFFF800000000007FFFFC0;
    char_snake[59] <= 192'h000FC00000001F0000000000000000000000000000000000;
    char_snake[60] <= 192'h00FC00000000070000000000000000000000000000000000;
    char_snake[61] <= 192'h038000000000000000000000000000000000000000000000;
    char_snake[62] <= 192'h000000000000000000000000000000000000000000000000;
    char_snake[63] <= 192'h000000000000000000000000000000000000000000000000;
end

//rgb
reg [4:0] row,col;
reg [5:0] cnt_50_raw,cnt_50_col;
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		rgb <=24'd0;
	end
	else if (cnt_h < H_START +340) begin//游戏介绍界面                
	//"得分"
    if(((cnt_h >= CHAR_B_H_score-1)&&(cnt_h < (CHAR_B_H_score + CHAR_W_score-1)))
                &&((cnt_v >= CHAR_B_V_score)&&(cnt_v < (CHAR_B_V_score + CHAR_H_score)))
               &&(char_score[char_y_score+24][128-char_x_score] == 1'b1))begin
        rgb <= 24'hFFFFFF;
    end
    //分数十位：    
    else if(((cnt_h >= CHAR_B_H0-1)&&(cnt_h < (CHAR_B_H0 + CHAR_W0-1)))&&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))begin
            if(score[1]&&(char1[char_y0+24][32-char_x0] == 1'b1))begin
        rgb <= 24'hFFFFFF;
        end
        else if((!score[1])&&(char0[char_y0+24][32-char_x0] == 1'b1))begin
        rgb <= 24'hFFFFFF;
        end
        else begin
        rgb <=24'h0000FF;
        end
     end
     //分数个位   
    else if(((cnt_h >= CHAR_B_H01-1)&&(cnt_h < (CHAR_B_H01 + CHAR_W0-1)))&&((cnt_v >= CHAR_B_V0)&&(cnt_v < (CHAR_B_V0 + CHAR_H0))))begin
      if((score[0]==0)&&(char0[char_y01][32-char_x01] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((score[0] == 1)&&(char1[char_y01][32-char_x01] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((score[0] == 2)&&(char2[char_y01][32-char_x01] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((score[0] == 3)&&(char3[char_y01][32-char_x01] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((score[0] == 4)&&(char4[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else if((score[0] == 5)&&(char5[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else if((score[0] == 6)&&(char6[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else if((score[0] == 7)&&(char7[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else if((score[0] == 8)&&(char8[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else if((score[0] == 9)&&(char9[char_y01][32-char_x01] == 1'b1)) begin rgb <= 24'hFFFFFF; end
      else begin rgb <=24'h0000FF; end
    end
    //贪吃蛇、游戏、模式
    else if(((cnt_h >= CHAR_B_H_game-1)&&(cnt_h < (CHAR_B_H_game + CHAR_W_score-1)))
                &&((cnt_v >= CHAR_B_V_game)&&(cnt_v < (CHAR_B_V_game + CHAR_H_score)))
                &&(char_game[char_y_game+35][128-char_x_game] == 1'b1))begin
        rgb <= 24'hFFFFFF;
        end
    else if(((cnt_h >= CHAR_B_H_snake-1)&&(cnt_h < (CHAR_B_H_snake + CHAR_W_snake-1)))
                &&((cnt_v >= CHAR_B_V_snake)&&(cnt_v < (CHAR_B_V_snake + CHAR_H_snake)))
               &&(char_snake[char_y_snake+15][192-char_x_snake] == 1'b1))begin
        rgb <= 24'hFFFFFF;
    end
    else if(((cnt_h >= CHAR_B_H_mode-1)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score-1)))
                &&((cnt_v >= CHAR_B_V_mode_1)&&(cnt_v < (CHAR_B_V_mode_1 + CHAR_H_score)))
                &&(char_mode[char_y_mode_1+22][128-char_x_mode_1] == 1'b1))begin
        rgb <= 24'hFFFFFF;
    end   
    //模式选择
    else if(((cnt_h >= CHAR_B_H_mode-1)&&(cnt_h < (CHAR_B_H_mode + CHAR_W_score-1)))&&((cnt_v >= CHAR_B_V_mode_2)&&(cnt_v < (CHAR_B_V_mode_2 + CHAR_H_score))))begin
      if((mode==2'd0)&&(char_mode1[char_y_mode_2+10][128-char_x_mode_2] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((mode==2'd1)&&(char_mode2[char_y_mode_2+10][128-char_x_mode_2] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((mode==2'd2)&&(char_mode3[char_y_mode_2+10][128-char_x_mode_2] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else if((mode==2'd3)&&(char_mode4[char_y_mode_2+10][128-char_x_mode_2] == 1'b1))begin rgb <= 24'hFFFFFF;end
      else begin rgb <=24'h0000FF; end
    end
    else begin 
        rgb <=24'h0000FF;//bulue
    end
  end
    
  //贪吃蛇和边框界面
  else if(cnt_h >= H_START +340) begin
  //游戏结束
    if(gameover)begin
        if(((cnt_h >= CHAR_B_H-1)&&(cnt_h < (CHAR_B_H + CHAR_W-1)))
                &&((cnt_v >= CHAR_B_V)&&(cnt_v < (CHAR_B_V + CHAR_H)))
                &&(char[char_y+24][255-char_x] == 1'b1))begin
           rgb <= 24'hFFFFFF;
        end
        else begin
             rgb<=24'd0;
         end
         end
    //游戏中
      else begin
          if ((cnt_h < H_START +340+ BORDER || cnt_h >= H_END - BORDER) || // 左右边框
              (cnt_v < V_START + BORDER || cnt_v >= V_END - BORDER)) begin // 上下边框
                if(mode[1])begin rgb <= 24'hFF0000; end
                else if(!mode[1])begin rgb <=24'h0000FF; end
                else begin rgb<=24'd0; end
           end
           else  
		if({row,col}=={block_x0,block_y0})begin
			rgb <= 24'hF8F8FF;
		end else if({row,col}=={block_x1,block_y1})begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x2,block_y2})&&lenth>=2)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x3,block_y3})&&lenth>=3)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x4,block_y4})&&lenth>=4)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x5,block_y5})&&lenth>=5)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x6,block_y6})&&lenth>=6)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x7,block_y7})&&lenth>=7)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x8,block_y8})&&lenth>=8)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x9,block_y9})&&lenth>=9)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x10,block_y10})&&lenth>=10)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x11,block_y11})&&lenth>=11)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x12,block_y12})&&lenth>=12)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x13,block_y13})&&lenth>=13)
		begin
			rgb <= 24'hF8F8FF;
		end else if(({row,col}=={block_x14,block_y14})&&lenth>=14)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x15,block_y15})&&lenth>=15)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x16,block_y16})&&lenth>=16)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x17,block_y17})&&lenth>=17)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x18,block_y18})&&lenth>=18)
		begin
			rgb <= 24'h54FFDE;
		end else if(({row,col}=={block_x19,block_y19})&&lenth>=19)
		begin
			rgb <= 24'h54FFDE;
		end else if({row,col}=={apple_xr,apple_yr})begin
			rgb <= 24'hCD5C5C;
		end 
		else begin
			rgb <= 24'h000000;
		end
		end
end
else begin
			rgb <= 24'h000000;
		end
end

//参考行列的扫描进行计数，将贪吃蛇显示区域以50x50大小计数，横row，竖col
always@(posedge vpg_pclk)begin
	if((rst==1'b1)||(vpg_vs==1'b1))begin
	row<=5'b0;
	col<=5'b0;
	cnt_50_raw<=6'd0;
	cnt_50_col<=6'd0;
	end
	else if(!(cnt_h<H_START+380||cnt_h>=H_START+380+1500||cnt_v<80||cnt_v>=1080)) begin//选择扫描区域
		if(cnt_50_raw==49)begin//横向扫完50个像素点
				cnt_50_raw <= 6'b0;
				if(row==29)begin
					row <= 5'b0;
					if(cnt_50_col==49)begin//竖向扫完50个像素点
					cnt_50_col <= 6'b0;
							if(col==29)begin
							col<=5'b0;
							end
							else begin
								col<=col+1'b1;
							end
					end
					else begin
					cnt_50_col <= cnt_50_col + 1'b1;//扫描竖向像素点进行计数
					end
				end
				else begin
				row <= row + 1'b1;
				end
			end
			else begin
				cnt_50_raw <= cnt_50_raw + 1'b1;//扫描横向像素点进行计数
			end
	end
end

endmodule
