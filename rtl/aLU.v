`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2026 02:51:10 PM
// Design Name: 
// Module Name: alu
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


module alu(
input wire [31:0] a,b,
input wire [3:0] alu_ctl,
output reg [31:0] rsult,
output wire zero
    );
    assign zero = (rsult == 32'b0);
    always @(*) begin
    case( alu_ctl) 
    4'b0000 : rsult = a + b;
    4'b0001 : rsult = a - b;
    4'b0010 : rsult = a & b;
    4'b0011 : rsult = a | b;
    4'b0100 : rsult = a ^ b;
    4'b0101 : rsult =  a << b[4:0];
    4'b0110 : rsult =  a >> b[4:0];
    4'b0111 : rsult = $signed (a) >>> b[4:0]; 
    4'b1000 : rsult =  ($signed (a) <$signed( b)) ? 32'd1 : 32'd0 ;
    4'b1001 : rsult =  (a < b) ? 32'd1 : 32'd0;
   default  : rsult = 32'b0;
   endcase
   end 
     
endmodule
