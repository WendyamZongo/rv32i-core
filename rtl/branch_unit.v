`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 04:51:42 PM
// Design Name: 
// Module Name: branch_unit
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


`timescale 1ns / 1ps

module branch_unit (
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [2:0]  funct3,
    output reg         taken
);

    always @(*) begin
        case (funct3)
            3'b000 : taken = (rs1_data == rs2_data);                    // beq
            3'b001 : taken = (rs1_data != rs2_data);                    // bne
            3'b100 : taken = ($signed(rs1_data) <  $signed(rs2_data));  // blt
            3'b101 : taken = ($signed(rs1_data) >= $signed(rs2_data));  // bge
            3'b110 : taken = (rs1_data <  rs2_data);                    // bltu
            3'b111 : taken = (rs1_data >= rs2_data);                    // bgeu
            default: taken = 1'b0;
        endcase
    end

endmodule