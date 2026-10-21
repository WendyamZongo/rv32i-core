`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 03:05:00 PM
// Design Name: 
// Module Name: imem
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


module imem(
input wire [31:0] addr,
output wire [31:0] inst
    );
    reg [31:0] mem [0:255];
    initial begin
     $readmemh ("C:/Users/pc/Documents/RTL/programme.hex",mem);
    end
     assign inst = mem [ addr [31:2]];
endmodule
