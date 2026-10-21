`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 04:01:24 PM
// Design Name: 
// Module Name: dmem
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


module dmem(
input wire clk,we,
input wire [31:0] addr,wdata,
output wire [31:0] rdata
    );
    reg [31:0] mem [0:255];
    assign rdata = mem [ addr [31:2]];
    always @ (posedge clk) begin
    if (we)
        mem [ addr[31:2]] <= wdata;
    end
endmodule
