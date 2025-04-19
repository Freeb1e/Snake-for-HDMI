`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 21:02:41
// Design Name: 
// Module Name: Apple_Gen
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

module Apple_Gen #(
    parameter [9:0] SEED_X = 10'b0000000001, // Seed for LFSR x
    parameter [9:0] SEED_Y = 10'b0001000100  // Seed for LFSR y
)(
    input clk,
    input rst,
    output reg [4:0] rand_x, // 5-bit output to represent numbers from 0 to 30
    output reg [4:0] rand_y  // 5-bit output to represent numbers from 0 to 20
);

    reg [9:0] lfsr_x;
    reg [9:0] lfsr_y;
    wire feedback_x;
    wire feedback_y;

    // Feedback polynomial for 10-bit LFSR: x^10 + x^7 + 1
    assign feedback_x = lfsr_x[9] ^ lfsr_x[6];
    assign feedback_y = lfsr_y[9] ^ lfsr_y[6];

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            lfsr_x <= SEED_X; // Initialize LFSR for x with seed
            lfsr_y <= SEED_Y; // Initialize LFSR for y with seed
        end else begin
            lfsr_x <= {lfsr_x[8:0], feedback_x}; // Shift and feedback for x
            lfsr_y <= {lfsr_y[8:0], feedback_y}; // Shift and feedback for y
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rand_x <= 5'b10;
            rand_y <= 5'b10;
        end else begin
            rand_x <= lfsr_x[4:0] % 30; // Generate a number between 0 and 30 for x
            rand_y <= lfsr_y[4:0] % 20; // Generate a number between 0 and 20 for y
//            if (rand_x == rand_y) begin
//                rand_y <= (rand_y + 1) % 21; // Ensure rand_y is not equal to rand_x
//            end
        end
    end
endmodule
