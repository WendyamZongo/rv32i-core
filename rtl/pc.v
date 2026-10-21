`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 04:48:51 PM
// Design Name: 
// Module Name: pc
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


module pc(
input wire clk,rst,
input wire [31:0] pc_next,
output reg [31:0] pc
    );
    always @(posedge clk) begin
        if (rst)
            pc <= 32'b00000000;
        else
            pc <= pc_next;
    end
endmodule
