`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 04:56:11 PM
// Design Name: 
// Module Name: branchUnit_tb
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
module branch_unit_tb;

    reg  [31:0] rs1_data;
    reg  [31:0] rs2_data;
    reg  [2:0]  funct3;
    wire        taken;

    integer erreurs;

    localparam BEQ = 3'b000, BNE = 3'b001;
    localparam BLT = 3'b100, BGE = 3'b101;
    localparam BLTU= 3'b110, BGEU= 3'b111;

    branch_unit dut (
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .funct3   (funct3),
        .taken    (taken)
    );

    //-----------------------------------------------------------------
    task verifier;
        input [95:0] nom;          // 12 caracteres
        input [31:0] v1;
        input [31:0] v2;
        input [2:0]  vf3;
        input        attendu;
        begin
            rs1_data = v1;  rs2_data = v2;  funct3 = vf3;
            #10;
            if (taken === attendu)
                $display("  OK     %0s  %h %h  ->  taken=%b", nom, v1, v2, taken);
            else begin
                $display("  ECHEC  %0s  %h %h  ->  taken=%b   attendu %b",
                         nom, v1, v2, taken, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test branch_unit");
        $display("=============================================");

        // ---------- beq / bne ----------
        $display("");
        $display("-- beq / bne --");
        verifier("beq egal    ", 32'd5, 32'd5, BEQ, 1'b1);
        verifier("beq different", 32'd5, 32'd7, BEQ, 1'b0);
        verifier("bne egal    ", 32'd5, 32'd5, BNE, 1'b0);
        verifier("bne different", 32'd5, 32'd7, BNE, 1'b1);
        verifier("beq zeros   ", 32'd0, 32'd0, BEQ, 1'b1);

        // ---------- blt / bge, signes ----------
        $display("");
        $display("-- blt / bge : comparaison SIGNEE --");
        verifier("blt 3 < 5   ", 32'd3, 32'd5, BLT, 1'b1);
        verifier("blt 5 < 3   ", 32'd5, 32'd3, BLT, 1'b0);
        verifier("blt 5 < 5   ", 32'd5, 32'd5, BLT, 1'b0);
        verifier("blt -1 < 5  ", 32'hFFFF_FFFF, 32'd5, BLT, 1'b1);
        verifier("blt 5 < -1  ", 32'd5, 32'hFFFF_FFFF, BLT, 1'b0);
        verifier("bge 5 >= 3  ", 32'd5, 32'd3, BGE, 1'b1);
        verifier("bge 5 >= 5  ", 32'd5, 32'd5, BGE, 1'b1);
        verifier("bge -1 >= 5 ", 32'hFFFF_FFFF, 32'd5, BGE, 1'b0);

        // ---------- bltu / bgeu, non signes ----------
        $display("");
        $display("-- bltu / bgeu : comparaison NON SIGNEE --");
        verifier("bltu 3 < 5  ", 32'd3, 32'd5, BLTU, 1'b1);
        verifier("bltu FF < 5 ", 32'hFFFF_FFFF, 32'd5, BLTU, 1'b0);
        verifier("bgeu FF >= 5", 32'hFFFF_FFFF, 32'd5, BGEU, 1'b1);
        verifier("bgeu 5 >= 5 ", 32'd5, 32'd5, BGEU, 1'b1);
        verifier("bgeu 3 >= 5 ", 32'd3, 32'd5, BGEU, 1'b0);

        // ---------- la paire decisive ----------
        $display("");
        $display("-- memes entrees, verdicts opposes --");
        $display("   (c'est ce qui prouve que les $signed sont a leur place)");
        verifier("blt  -1 vs 5", 32'hFFFF_FFFF, 32'd5, BLT,  1'b1);
        verifier("bltu -1 vs 5", 32'hFFFF_FFFF, 32'd5, BLTU, 1'b0);

        // ---------- funct3 non defini ----------
        $display("");
        $display("-- funct3 sans branchement associe --");
        verifier("funct3 = 010", 32'd5, 32'd5, 3'b010, 1'b0);
        verifier("funct3 = 011", 32'd5, 32'd5, 3'b011, 1'b0);

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