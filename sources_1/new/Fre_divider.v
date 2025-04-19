`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 21:09:39
// Design Name: 
// Module Name: Fre_divider
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


module Fre_divider (
    input wire clk_50M,   // 50 MHz 输入时钟
    input wire rst,       // 异步复位信号
    output reg clk_out,    // 输出时钟信号
    input wire [24:0] DIVISOR
    );

    reg [24:0] counter;   // 计数器，25位可以计数到 2^25 - 1 = 33,554,431

    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            counter <= 25'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter <= 25'd0;
                clk_out <= ~clk_out;  // 翻转输出时钟信号
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
