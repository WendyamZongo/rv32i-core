`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2026 03:28:56 PM
// Design Name: 
// Module Name: alu_tb
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

//=====================================================================
//  Banc de test pour alu.v
//
//  Compilation et exécution :
//      iverilog -o alu_tb.out alu_tb.v alu.v
//      vvp alu_tb.out
//
//  Chaque vecteur affiche OK ou ECHEC. Un compteur d'erreurs donne
//  le verdict final.
//=====================================================================

module alu_tb;

    // ---- signaux reliés à l'ALU ----
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctl;
    wire [31:0] rsult;
    wire        zero;

    integer erreurs;

    // ---- codes de commande, pour la lisibilité ----
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    // ---- instanciation du module testé ----
    alu dut (
        .a        (a),
        .b        (b),
        .alu_ctl  (alu_ctl),
        .rsult    (rsult),
        .zero     (zero)
    );

    //-----------------------------------------------------------------
    //  verifier : applique un vecteur et compare au résultat attendu
    //-----------------------------------------------------------------
    task verifier;
        input [39:0] nom;        // 5 caractères, complété par des espaces
        input [31:0] va;
        input [31:0] vb;
        input [3:0]  ctrl;
        input [31:0] attendu;
        begin
            a        = va;
            b        = vb;
            alu_ctl = ctrl;
            #10;
            if (rsult === attendu)
                $display("  OK     %0s  a=%h  b=%h  ->  %h", nom, va, vb, rsult);
            else begin
                $display("  ECHEC  %0s  a=%h  b=%h  ->  %h   attendu %h",
                         nom, va, vb, rsult, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    //  verif_zero : contrôle le drapeau zéro
    //-----------------------------------------------------------------
    task verif_zero;
        input [31:0] va;
        input [31:0] vb;
        input [3:0]  ctrl;
        input        attendu;
        begin
            a        = va;
            b        = vb;
            alu_ctl = ctrl;
            #10;
            if (zero === attendu)
                $display("  OK     zero   rsult=%h  ->  zero=%b", rsult, zero);
            else begin
                $display("  ECHEC  zero   rsult=%h  ->  zero=%b   attendu %b",
                         rsult, zero, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test ALU");
        $display("=============================================");

        // ---------- arithmétique ----------
        $display("");
        $display("-- add / sub --");
        verifier("add  ", 32'h0000_0005, 32'h0000_0003, ALU_ADD, 32'h0000_0008);
        verifier("add  ", 32'hFFFF_FFFF, 32'h0000_0001, ALU_ADD, 32'h0000_0000); // -1 + 1
        verifier("add  ", 32'hFFFF_FFFF, 32'hFFFF_FFFF, ALU_ADD, 32'hFFFF_FFFE); // -1 + -1
        verifier("sub  ", 32'h0000_0005, 32'h0000_0003, ALU_SUB, 32'h0000_0002);
        verifier("sub  ", 32'h0000_0003, 32'h0000_0005, ALU_SUB, 32'hFFFF_FFFE); // 3-5 = -2

        // ---------- logique ----------
        $display("");
        $display("-- and / or / xor --");
        verifier("and  ", 32'hF0F0_F0F0, 32'hFF00_FF00, ALU_AND, 32'hF000_F000);
        verifier("or   ", 32'hF0F0_F0F0, 32'h0F0F_0F0F, ALU_OR,  32'hFFFF_FFFF);
        verifier("xor  ", 32'hFFFF_0000, 32'h00FF_FF00, ALU_XOR, 32'hFF00_FF00);

        // ---------- décalages ----------
        $display("");
        $display("-- sll / srl / sra --");
        verifier("sll  ", 32'h0000_0005, 32'h0000_0002, ALU_SLL, 32'h0000_0014); // 5 << 2 = 20
        verifier("sll  ", 32'h0000_0001, 32'h0000_001F, ALU_SLL, 32'h8000_0000); // << 31
        verifier("sll  ", 32'h0000_0001, 32'h0000_0021, ALU_SLL, 32'h0000_0002); // 33 -> 1
        verifier("srl  ", 32'h8000_0000, 32'h0000_0004, ALU_SRL, 32'h0800_0000);
        verifier("srl  ", 32'hFFFF_FFF8, 32'h0000_0001, ALU_SRL, 32'h7FFF_FFFC); // zéro en tête
        verifier("sra  ", 32'hFFFF_FFF8, 32'h0000_0001, ALU_SRA, 32'hFFFF_FFFC); // -8 >> 1 = -4
        verifier("sra  ", 32'hFFFF_FFFF, 32'h0000_000F, ALU_SRA, 32'hFFFF_FFFF); // -1 reste -1
        verifier("sra  ", 32'h0000_0010, 32'h0000_0002, ALU_SRA, 32'h0000_0004); // positif

        // ---------- comparaisons ----------
        $display("");
        $display("-- slt / sltu --");
        verifier("slt  ", 32'hFFFF_FFFF, 32'h0000_0005, ALU_SLT,  32'h0000_0001); // -1 < 5
        verifier("slt  ", 32'h0000_0005, 32'hFFFF_FFFF, ALU_SLT,  32'h0000_0000); // 5 < -1 faux
        verifier("slt  ", 32'h0000_0003, 32'h0000_0005, ALU_SLT,  32'h0000_0001);
        verifier("slt  ", 32'h0000_0005, 32'h0000_0005, ALU_SLT,  32'h0000_0000); // égalité
        verifier("sltu ", 32'hFFFF_FFFF, 32'h0000_0005, ALU_SLTU, 32'h0000_0000); // non signé
        verifier("sltu ", 32'h0000_0003, 32'h0000_0005, ALU_SLTU, 32'h0000_0001);

        // ---------- drapeau zéro ----------
        $display("");
        $display("-- drapeau zero --");
        verif_zero(32'h0000_0005, 32'h0000_0005, ALU_SUB, 1'b1); // 5-5 = 0
        verif_zero(32'h0000_0005, 32'h0000_0003, ALU_SUB, 1'b0); // 5-3 = 2

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
