`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 01:38:43 PM
// Design Name: 
// Module Name: control
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


module control(
input wire [6:0] opcode,
output reg [2:0] im_src,
output reg [1:0] alu_src_a, alu_op, wb_sel,
output reg write_mem, read_mem, jump,branch, alu_src_b, reg_write
    );
    always @ (*) begin
        reg_write = 1'b0;
        alu_src_b = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        read_mem = 1'b0;
        write_mem = 1'b0;
        alu_src_a = 2'b00;
        alu_op = 2'b00;
        wb_sel = 2'b00;
        im_src = 3'b000;
        
        case (opcode)

            7'b0110011 : begin                      // R
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end

            7'b0010011 : begin                      // I arithmétique
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                alu_op    = 2'b10;
            end

            7'b0000011 : begin                      // load
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                read_mem  = 1'b1;
                wb_sel    = 2'b01;
            end

            7'b0100011 : begin                      // store
                im_src    = 3'b001;
                alu_src_b = 1'b1;
                write_mem = 1'b1;
            end

            7'b1100011 : begin                      // branch
                im_src    = 3'b010;
                branch    = 1'b1;
                alu_op    = 2'b01;
            end

            7'b1101111 : begin                      // jal
                reg_write = 1'b1;
                im_src    = 3'b100;
                alu_src_a = 2'b01;
                alu_src_b = 1'b1;
                wb_sel    = 2'b10;
                jump      = 1'b1;
            end

            7'b1100111 : begin                      // jalr
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                wb_sel    = 2'b10;
                jump      = 1'b1;
            end

            7'b0110111 : begin                      // lui
                reg_write = 1'b1;
                im_src    = 3'b011;
                alu_src_a = 2'b10;
                alu_src_b = 1'b1;
            end

            7'b0010111 : begin                      // auipc
                reg_write = 1'b1;
                im_src    = 3'b011;
                alu_src_a = 2'b01;
                alu_src_b = 1'b1;
            end
        default : ;
        endcase
        end
endmodule
