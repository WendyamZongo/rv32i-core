`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 03:47:29 PM
// Design Name: 
// Module Name: aluControl
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


module aluControl(
input wire [1:0] alu_op,
input wire [2:0] fnct,
input wire op_5,inst,
output reg [3:0] alu_ctl
    );
    always @(*) begin 
    case (alu_op)
        2'b00 : alu_ctl = 4'b0000;
        2'b01 : alu_ctl = 4'b0001;
        2'b10 : begin
            case (fnct)
            3'b000 : alu_ctl = (inst && op_5) ? 4'b0001 : 4'b0000;
            3'b001 : alu_ctl = 4'b0101;     // sll
            3'b010 : alu_ctl = 4'b1000;     // slt
            3'b011 : alu_ctl = 4'b1001;     // sltu
            3'b100 : alu_ctl = 4'b0100;     // xor
            3'b101 : alu_ctl = inst ? 4'b0111 : 4'b0110;
            3'b110 : alu_ctl = 4'b0011;     // or
            3'b111 : alu_ctl = 4'b0010;     // and
            default: alu_ctl = 4'b0000;
            endcase
        end
         default : alu_ctl = 4'b0000;
                 
    endcase
    end
endmodule
