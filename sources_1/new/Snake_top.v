`timescale 1ns / 1ps
module Snake_top(
    input wire clk,
    input wire [3:0] dir,
    input wire rst,
    output 	wire 			hdmi_tx_clk_n	,
	output 	wire 			hdmi_tx_clk_p	,
	output 	wire 			hdmi_tx_chn_r_n	,
	output 	wire 			hdmi_tx_chn_r_p	,
	output 	wire 			hdmi_tx_chn_g_n	,
	output 	wire 			hdmi_tx_chn_g_p	,
	output 	wire 			hdmi_tx_chn_b_n	,
	output 	wire 			hdmi_tx_chn_b_p	,
    input wire uart_rxd,
    output wire uart_txd
    );//clk:50M的输入信号
    parameter SUP = 3'd1, SLEFT = 3'd2, SDOWN = 3'd3, SRIGHT = 3'd4;
(* DONT_TOUCH = "TRUE", keep = "true" *) reg [4:0] block_x[0:19];
(* DONT_TOUCH = "TRUE", keep = "true" *) reg [4:0] block_y[0:19];
wire [4:0] apple_x,apple_y;
wire clk_move;
//wire dx,dy;
wire [2:0] direction;
reg [4:0] lenth;//蛇的长度
reg [4:0] apple_xr,apple_yr;
wire [1:0] mode;
reg [24:0] DIVISOR;//0.5s
//总棋盘大小 30*20 range 29*19
integer i;
reg gameover_self;
reg gameover_wall;
wire gameover;
reg wall;
reg clk_move_1;
wire pause;

wire rst1;


assign gameover=gameover_self||gameover_wall;

always @(posedge clk_move or negedge rst)//蛇的位置移动
begin
    if((!rst)||(!rst1))begin//初始化蛇的位置
        for(i = 0; i <= 15; i = i + 1) //前面16节横向摆放
        begin
            block_x[i]<=15-i;
            block_y[i]<=10;
        end
        for(i=16; i<=19; i=i+1)//后面4节纵向摆放
        begin
            block_x[i]<=0;
            block_y[i]<=26-i;
        end
        gameover_wall<=0;
    end
    else if((!gameover_self)&&(!gameover_wall)&&(!pause))begin
        for(i=1; i<=19; i=i+1)
        begin
            block_x[i]<=block_x[i-1];
            block_y[i]<=block_y[i-1];
        end
        case(direction)
         SUP:begin
            if(block_y[0]==0)begin
                if(wall)begin
                    gameover_wall<=1;
                end
                else begin
                    block_y[0]<=19;
                end
            end
            else begin
                block_y[0]<=block_y[0]-1;
            end

            block_x[0]<=block_x[0];
            end
           SLEFT:begin 
            block_y[0]<=block_y[0];
            if(block_x[0]==0)begin
                if(wall)begin
                    gameover_wall<=1;
                end
                else begin
                    block_x[0]<=29;
                end
            end
            else begin
                block_x[0]<=block_x[0]-1;
            end
            end
            SDOWN:begin
            if(block_y[0]==19)begin
                if(wall)begin
                    gameover_wall<=1;
                end
                else begin
                    block_y[0]<=0;
            end
            end
            else begin
                block_y[0]<=block_y[0]+1;
            end
            block_x[0]<=block_x[0];
            end
            SRIGHT:begin
            block_y[0]<=block_y[0];
            if(block_x[0]==29)begin
                if(wall)begin
                    gameover_wall<=1;
                end
                else begin
                    block_x[0]<=0;
            end
            end
            else begin
            block_x[0]<=block_x[0]+1;
            end
            end
            default:begin
            block_y[0]<=block_y[0];
            block_x[0]<=block_x[0];
            end
    endcase
    end
end


always @(posedge clk or negedge rst1)
begin
    if((!rst)||(!rst1))
    begin
        gameover_self<=0;
    end else begin
    for(i=1; i<=19; i=i+1)
    begin
        if((block_x[0]==block_x[i])&&(block_y[0]==block_y[i])&&lenth>=i)begin
            gameover_self<=1;
        end
    end
    end
end


always @(posedge clk or negedge rst )
begin
    if(!rst)
    begin
        DIVISOR<=25000000;
        wall<=0;
    end
    else begin
        case(mode)
            2'd0:begin 
                DIVISOR<=25000000;
                wall<=0;
            end
            2'd1:begin
            DIVISOR<=15000000;
            wall<=0;
            end
            2'd2:begin
            DIVISOR<=25000000;
            wall<=1;
            end
            2'd3:begin
            DIVISOR<=10000000;
            wall<=1;
            end
            default:begin
            DIVISOR<=25000000;
            wall<=0;
            end
        endcase
    end
end



always@(posedge clk or negedge rst)//打拍器，让判断苹果和撞墙在clk_move的后面进行
begin
    if(!rst)begin
        clk_move_1<=0;
    end
    else begin
        clk_move_1<=clk_move;
    end
end

reg gen_flag;
always @(posedge clk_move_1 or negedge rst )//判断是否吃到苹果,编辑蛇身体长度,判断时间是蛇移动之后的一个clk
begin
    if((!rst)||(!rst1))begin
        lenth<=1;
        //gen_flag<=1;
    end else 
        if((block_x[0]==apple_xr)&&(block_y[0]==apple_yr))begin
            lenth<=lenth+1;
           // gen_flag<=1;//吃到苹果,说明需要产生新的苹果
        end
end

always @(posedge clk or negedge rst )//产生新的苹果
begin
    if((!rst)||(!rst1))begin
        gen_flag<=1;
        end
    else if(gen_flag)begin
        //判断苹果是否在蛇的身体上，如果还在的话则继续生成新的苹果
        apple_xr<=apple_x;apple_yr<=apple_y;
    end
    gen_flag<=((apple_xr==block_x[0])&&(apple_yr==block_y[0]))||((apple_xr==block_x[1])&&(apple_yr==block_y[1]))
        ||((apple_xr==block_x[2])&&(apple_yr==block_y[2])&&(lenth>=2))||((apple_xr==block_x[3])&&(apple_yr==block_y[3])&&(lenth>=3))
        ||((apple_xr==block_x[4])&&(apple_yr==block_y[4])&&(lenth>=4))||((apple_xr==block_x[5])&&(apple_yr==block_y[5])&&(lenth>=5))
        ||((apple_xr==block_x[6])&&(apple_yr==block_y[6])&&(lenth>=6))||((apple_xr==block_x[7])&&(apple_yr==block_y[7])&&(lenth>=7))
        ||((apple_xr==block_x[8])&&(apple_yr==block_y[8])&&(lenth>=8))||((apple_xr==block_x[9])&&(apple_yr==block_y[9])&&(lenth>=9))
        ||((apple_xr==block_x[10])&&(apple_yr==block_y[10])&&(lenth>=10))||((apple_xr==block_x[11])&&(apple_yr==block_y[11])&&(lenth>=11))
        ||((apple_xr==block_x[12])&&(apple_yr==block_y[12])&&(lenth>=12))||((apple_xr==block_x[13])&&(apple_yr==block_y[13])&&(lenth>=13))
        ||((apple_xr==block_x[14])&&(apple_yr==block_y[14])&&(lenth>=14))||((apple_xr==block_x[15])&&(apple_yr==block_y[15])&&(lenth>=15))
        ||((apple_xr==block_x[16])&&(apple_yr==block_y[16])&&(lenth>=16))||((apple_xr==block_x[17])&&(apple_yr==block_y[17])&&(lenth>=17))
        ||((apple_xr==block_x[18])&&(apple_yr==block_y[18])&&(lenth>=18))||((apple_xr==block_x[19])&&(apple_yr==block_y[19])&&(lenth>=19));
        //只要在生成状态，就更新苹果的位置，只要不重合了，gen_flag=0下个回合就不更新了，一共有50000000个周期的机会，一定会有符合条件的苹果

end

//Snake_direction Snake_direction_ctrl(.clk(clk), .dir(dir), .rst(rst), .dx(dx), .dy(dy));//通过输入来控制蛇的移动方向
uart_top uart1(
	.sys_clk(clk),	//系统时钟
	.sys_rst_n(rst),	//系统复位
 
	.uart_rxd(uart_rxd),	//接收端口
	.uart_txd(uart_txd),	//发送端口
	//.led
	.direction(direction),
    .mode(mode),
    .rst1(rst1),
    .pause(pause)
//	output  direction_order
);
Apple_Gen Apple_Gen_ctrl(.clk(clk), .rst(rst), .rand_x(apple_x), .rand_y(apple_y));//用反馈寄存器产生苹果的位置
Fre_divider Fre_divider_ctrl(.clk_50M(clk), .rst(rst), .clk_out(clk_move),.DIVISOR(DIVISOR));//分频器，蛇的位置0.5s移动一次
hdmi_trans_top hd(.clk(clk), 
                  .rst_n(rst),//注意该模块的复位信号为高有效 
                  .hdmi_tx_clk_n(hdmi_tx_clk_n), 
                  .hdmi_tx_clk_p(hdmi_tx_clk_p), 
                  .hdmi_tx_chn_r_n(hdmi_tx_chn_r_n), 
                  .hdmi_tx_chn_r_p(hdmi_tx_chn_r_p), 
                  .hdmi_tx_chn_g_n(hdmi_tx_chn_g_n),
                  .hdmi_tx_chn_g_p(hdmi_tx_chn_g_p), 
                  .hdmi_tx_chn_b_n(hdmi_tx_chn_b_n), 
                  .hdmi_tx_chn_b_p(hdmi_tx_chn_b_p),
                  .block_x0(block_x[0]),
                  .block_x1(block_x[1]),
                  .block_x2(block_x[2]),
                  .block_x3(block_x[3]),
                  .block_x4(block_x[4]),
                  .block_x5(block_x[5]),
                  .block_x6(block_x[6]),
                  .block_x7(block_x[7]),
                  .block_x8(block_x[8]),
                  .block_x9(block_x[9]),
                  .block_x10(block_x[10]),
                  .block_x11(block_x[11]),
                  .block_x12(block_x[12]),
                  .block_x13(block_x[13]),
                  .block_x14(block_x[14]),
                  .block_x15(block_x[15]),
                  .block_x16(block_x[16]),
                  .block_x17(block_x[17]),
                  .block_x18(block_x[18]),
                  .block_x19(block_x[19]),
                  .block_y0(block_y[0]),
                  .block_y1(block_y[1]),
                  .block_y2(block_y[2]),
                  .block_y3(block_y[3]),
                  .block_y4(block_y[4]),
                  .block_y5(block_y[5]),
                  .block_y6(block_y[6]),
                  .block_y7(block_y[7]),
                  .block_y8(block_y[8]),
                  .block_y9(block_y[9]),
                  .block_y10(block_y[10]),
                  .block_y11(block_y[11]),
                  .block_y12(block_y[12]),
                  .block_y13(block_y[13]),
                  .block_y14(block_y[14]),
                  .block_y15(block_y[15]),
                  .block_y16(block_y[16]),
                  .block_y17(block_y[17]),
                  .block_y18(block_y[18]),
                  .block_y19(block_y[19]),
                    .apple_xr(apple_xr),
                    .apple_yr(apple_yr),
                    .lenth(lenth),
                    .gameover(gameover),
                    .mode(mode)
                   );
endmodule
