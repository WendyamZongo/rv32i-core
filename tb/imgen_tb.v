`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 02:43:05 AM
// Design Name: 
// Module Name: imgen_tb
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

module imgen_tb;

    reg  [31:0] inst;
    reg  [2:0]  im_src;
    wire [31:0] imm;

    integer erreurs;

    localparam SRC_I = 3'b000;
    localparam SRC_S = 3'b001;
    localparam SRC_B = 3'b010;
    localparam SRC_U = 3'b011;
    localparam SRC_J = 3'b100;

    imGen dut (
        .inst   (inst),
        .im_src (im_src),
        .imm    (imm)
    );

    //-----------------------------------------------------------------
    task verifier;
        input [79:0] nom;        // 10 caracteres
        input [31:0] vinst;
        input [2:0]  vsrc;
        input [31:0] attendu;
        begin
            inst   = vinst;
            im_src = vsrc;
            #10;
            if (imm === attendu)
                $display("  OK     %0s  inst=%h  ->  imm=%h", nom, vinst, imm);
            else begin
                $display("  ECHEC  %0s  inst=%h  ->  imm=%h   attendu %h",
                         nom, vinst, imm, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test imGen");
        $display("=============================================");

        // ---------- format I ----------
        $display("");
        $display("-- format I : addi, lw --");
        // addi x5, x6, 42
        verifier("addi +42  ", 32'h02A3_0293, SRC_I, 32'h0000_002A);
        // addi x5, x6, -4
        verifier("addi -4   ", 32'hFFC3_0293, SRC_I, 32'hFFFF_FFFC);
        // addi x5, x6, 2047   (valeur maximale sur 12 bits signes)
        verifier("addi +2047", 32'h7FF3_0293, SRC_I, 32'h0000_07FF);
        // addi x5, x6, -2048  (valeur minimale)
        verifier("addi -2048", 32'h8003_0293, SRC_I, 32'hFFFF_F800);
        // lw x5, 0(x6)        (immediat nul)
        verifier("lw +0     ", 32'h0003_2283, SRC_I, 32'h0000_0000);

        // ---------- format S ----------
        $display("");
        $display("-- format S : sw --");
        // sw x5, 8(x6)
        verifier("sw +8     ", 32'h0053_2423, SRC_S, 32'h0000_0008);
        // sw x5, -8(x6)
        verifier("sw -8     ", 32'hFE53_2C23, SRC_S, 32'hFFFF_FFF8);

        // ---------- format B ----------
        $display("");
        $display("-- format B : beq --");
        // beq x5, x6, -16
        verifier("beq -16   ", 32'hFE62_88E3, SRC_B, 32'hFFFF_FFF0);
        // beq x5, x6, +16
        verifier("beq +16   ", 32'h0062_8863, SRC_B, 32'h0000_0010);

        // ---------- format U ----------
        $display("");
        $display("-- format U : lui --");
        // lui x5, 0x12345
        verifier("lui 12345 ", 32'h1234_52B7, SRC_U, 32'h1234_5000);
        // lui x5, 0xFFFFF   (pas d'extension de signe pour ce format)
        verifier("lui FFFFF ", 32'hFFFF_F2B7, SRC_U, 32'hFFFF_F000);

        // ---------- format J ----------
        $display("");
        $display("-- format J : jal --");
        // jal x1, 2048
        verifier("jal +2048 ", 32'h0010_00EF, SRC_J, 32'h0000_0800);
        // jal x1, -4
        verifier("jal -4    ", 32'hFFDF_F0EF, SRC_J, 32'hFFFF_FFFC);

        // ---------- cas par defaut ----------
        $display("");
        $display("-- code non prevu --");
        verifier("default   ", 32'hFFFF_FFFF, 3'b111, 32'h0000_0000);

        // ---------- verdict ----------
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
