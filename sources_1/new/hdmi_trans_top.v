// --------------------------------------------------------------------
// Copyright (c) 2019 by MicroPhase Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   MicroPhase grants permission to use and modify this code for use
//   in synthesis for all MicroPhase Development Boards.
//   Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  MicroPhase provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     MicroPhase Technologies Inc
//                     Shanghai, China
//
//                     web: http://www.microphase.cn/   
//                     email: support@microphase.cn
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
// Major Functions:	
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
//  Revision History:
//  Date          By            Revision    Change Description
//---------------------------------------------------------------------
//2020-03-24      Chaochen Wei  1.0          Original
//2020-                         1.1          
// --------------------------------------------------------------------
// --------------------------------------------------------------------
`timescale 1ns / 1ps
module hdmi_trans_top(
	input	wire 			clk 		,
	input 	wire			rst_n 		,
	output 	wire 			hdmi_tx_clk_n	,
	output 	wire 			hdmi_tx_clk_p	,
	output 	wire 			hdmi_tx_chn_r_n	,
	output 	wire 			hdmi_tx_chn_r_p	,
	output 	wire 			hdmi_tx_chn_g_n	,
	output 	wire 			hdmi_tx_chn_g_p	,
	output 	wire 			hdmi_tx_chn_b_n	,
	output 	wire 			hdmi_tx_chn_b_p	,

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
	input wire gameover,
	input wire [1:0]mode
    );

parameter  	CNT_MAX 	= 	1000;

wire 				locked 		;
wire 				rst 		;
wire 				clk1x 		;
wire 				clk5x 		;
wire 	[7:0]		rgb_r 		;
wire 	[7:0]		rgb_g 		;
wire 	[7:0]		rgb_b 		;
wire 				vpg_de 		;
wire 				vpg_hs 		;
wire 				vpg_vs 		;
reg 				hdmi_oen_r 	;
reg 	[10:0]		cnt 		;

assign rst = ~locked;
assign hdmi_oen = hdmi_oen_r;

always @(posedge clk1x) begin
	if (rst==1'b1)begin
		cnt <= 'd0;
	end
	else if(cnt < CNT_MAX)begin
		cnt <= cnt + 1'b1;
	end
	else begin
		cnt <= cnt;
	end
end

always @(posedge clk1x) begin
	if (rst==1'b1) begin
		hdmi_oen_r <= 1'b0;
	end
	else if(cnt == CNT_MAX)begin
		hdmi_oen_r <= 1'b1;
	end
end



	clock inst_clock(
			// Clock out ports
			.clk_out1(clk1x),     // output clk_out1
			.clk_out2(clk5x),     // output clk_out2
			// Status and control signals
			.resetn(rst_n), 		// input resetn
			.locked(locked),       	// output locked
			// Clock in ports
			.clk_in1(clk) 		 // input clk_in1
	);     

	vga_shift  inst_vga_shift (
			.rst      (rst),
			.vpg_pclk (clk1x),
			.vpg_de   (vpg_de),
			.vpg_hs   (vpg_hs),
			.vpg_vs   (vpg_vs),
			.rgb_r    (rgb_r),
			.rgb_g    (rgb_g),
			.rgb_b    (rgb_b),//在这里进行蛇身位置的接入
			.block_x0(block_x0),
			.block_y0(block_y0),
			.block_x1(block_x1),
			.block_y1(block_y1),
			.block_x2(block_x2),
			.block_y2(block_y2),
			.block_x3(block_x3),
			.block_y3(block_y3),
			.block_x4(block_x4),
			.block_y4(block_y4),
			.block_x5(block_x5),
			.block_y5(block_y5),
			.block_x6(block_x6),
			.block_y6(block_y6),
			.block_x7(block_x7),
			.block_y7(block_y7),
			.block_x8(block_x8),
			.block_y8(block_y8),
			.block_x9(block_x9),
			.block_y9(block_y9),
			.block_x10 (block_x10),
			.block_y10 (block_y10),
			.block_x11 (block_x11),
			.block_y11 (block_y11),
			.block_x12 (block_x12),
			.block_y12 (block_y12),
			.block_x13 (block_x13),
			.block_y13 (block_y13),
			.block_x14 (block_x14),
			.block_y14 (block_y14),
			.block_x15 (block_x15),
			.block_y15 (block_y15),
			.block_x16 (block_x16),
			.block_y16 (block_y16),
			.block_x17 (block_x17),
			.block_y17 (block_y17),
			.block_x18 (block_x18),
			.block_y18 (block_y18),
			.block_x19 (block_x19),
			.block_y19 (block_y19),
			.apple_xr(apple_xr),
			.apple_yr(apple_yr),
			.lenth(lenth),
			.gameover(gameover),
			.mode(mode)
		);

	hdmi_trans inst_hdmi_trans(
			.clk1x           (clk1x),
			.clk5x           (clk5x),
			.rst             (rst),
			.image_r         (rgb_r),
			.image_g         (rgb_g),
			.image_b         (rgb_b),
			.vsync           (vpg_vs),
			.hsync           (vpg_hs),
			.de              (vpg_de),
			.hdmi_tx_clk_n   (hdmi_tx_clk_n),
			.hdmi_tx_clk_p   (hdmi_tx_clk_p),
			.hdmi_tx_chn_r_n (hdmi_tx_chn_r_n),
			.hdmi_tx_chn_r_p (hdmi_tx_chn_r_p),
			.hdmi_tx_chn_g_n (hdmi_tx_chn_g_n),
			.hdmi_tx_chn_g_p (hdmi_tx_chn_g_p),
			.hdmi_tx_chn_b_n (hdmi_tx_chn_b_n),
			.hdmi_tx_chn_b_p (hdmi_tx_chn_b_p)
		);



endmodule



