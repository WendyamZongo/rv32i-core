`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 02:07:00 PM
// Design Name: 
// Module Name: control_tb
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
//=====================================================================
//  Banc de test pour control
//
//  Verifie les dix signaux de controle pour les neuf opcodes RV32I,
//  plus un opcode invalide.
//=====================================================================

module control_tb;

    reg  [6:0] opcode;
    wire       reg_write;
    wire [2:0] im_src;
    wire [1:0] alu_src_a;
    wire       alu_src_b;
    wire       mem_read;
    wire       mem_write;
    wire [1:0] wb_sel;
    wire       branch;
    wire       jump;
    wire [1:0] alu_op;

    integer erreurs;

    control dut (
        .opcode    (opcode),
        .reg_write (reg_write),
        .im_src    (im_src),
        .alu_src_a (alu_src_a),
        .alu_src_b (alu_src_b),
        .read_mem  (mem_read),
        .write_mem (mem_write),
        .wb_sel    (wb_sel),
        .branch    (branch),
        .jump      (jump),
        .alu_op    (alu_op)
    );

    //-----------------------------------------------------------------
    //  verifier : applique un opcode et compare les dix signaux
    //-----------------------------------------------------------------
    task verifier;
        input [55:0] nom;         // 7 caracteres
        input [6:0]  vop;
        input        a_reg_write;
        input [2:0]  a_im_src;
        input [1:0]  a_alu_src_a;
        input        a_alu_src_b;
        input        a_mem_read;
        input        a_mem_write;
        input [1:0]  a_wb_sel;
        input        a_branch;
        input        a_jump;
        input [1:0]  a_alu_op;
        begin
            opcode = vop;
            #10;
            if (reg_write === a_reg_write && im_src    === a_im_src    &&
                alu_src_a === a_alu_src_a && alu_src_b === a_alu_src_b &&
                mem_read  === a_mem_read  && mem_write === a_mem_write &&
                wb_sel    === a_wb_sel    && branch    === a_branch    &&
                jump      === a_jump      && alu_op    === a_alu_op)
                $display("  OK     %0s  opcode=%b", nom, vop);
            else begin
                $display("  ECHEC  %0s  opcode=%b", nom, vop);
                $display("           obtenu  rw=%b im=%b sa=%b sb=%b mr=%b mw=%b wb=%b br=%b jp=%b op=%b",
                         reg_write, im_src, alu_src_a, alu_src_b,
                         mem_read, mem_write, wb_sel, branch, jump, alu_op);
                $display("           attendu rw=%b im=%b sa=%b sb=%b mr=%b mw=%b wb=%b br=%b jp=%b op=%b",
                         a_reg_write, a_im_src, a_alu_src_a, a_alu_src_b,
                         a_mem_read, a_mem_write, a_wb_sel, a_branch, a_jump, a_alu_op);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test control");
        $display("=============================================");
        $display("");
        $display("              rw  im   sa  sb  mr  mw  wb   br  jp  op");

        //                       rw     im      sa     sb    mr    mw    wb     br    jp    op
        verifier("R      ", 7'b0110011, 1'b1, 3'b000, 2'b00, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10);
        verifier("I arith", 7'b0010011, 1'b1, 3'b000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10);
        verifier("load   ", 7'b0000011, 1'b1, 3'b000, 2'b00, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00);
        verifier("store  ", 7'b0100011, 1'b0, 3'b001, 2'b00, 1'b1, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 2'b00);
        verifier("branch ", 7'b1100011, 1'b0, 3'b010, 2'b00, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, 2'b01);
        verifier("jal    ", 7'b1101111, 1'b1, 3'b100, 2'b01, 1'b1, 1'b0, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00);
        verifier("jalr   ", 7'b1100111, 1'b1, 3'b000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00);
        verifier("lui    ", 7'b0110111, 1'b1, 3'b011, 2'b10, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00);
        verifier("auipc  ", 7'b0010111, 1'b1, 3'b011, 2'b01, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00);

        $display("");
        $display("-- opcode invalide : tout doit rester inactif --");
        verifier("invalide", 7'b1111111, 1'b0, 3'b000, 2'b00, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00);

        $display("");
        $display("=============================================");
        if (erreurs == 0)
            $display("  RESULTAT : tous les vecteurs passent");
        else
            $display("  RESULTAT : %0d erreur(s)", erreurs);
        $display("=============================================");
        $display("");
        $finish;
    end

endmodule
