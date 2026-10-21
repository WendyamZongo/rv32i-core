`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 04:59:02 PM
// Design Name: 
// Module Name: pc_tb
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
module pc_tb;

    reg         clk;
    reg         rst;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    integer erreurs;

    pc dut (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc)
    );

    // horloge : periode de 10 ns
    always #5 clk = ~clk;

    //-----------------------------------------------------------------
    //  verifier : compare la valeur courante du pc
    //-----------------------------------------------------------------
    task verifier;
        input [151:0] nom;        // 19 caracteres
        input [31:0]  attendu;
        begin
            if (pc === attendu)
                $display("  OK     %0s  pc = %h", nom, pc);
            else begin
                $display("  ECHEC  %0s  pc = %h   attendu %h", nom, pc, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        pc_next = 32'h0000_0000;
        erreurs = 0;

        $display("");
        $display("=============================================");
        $display("  Banc de test pc");
        $display("=============================================");

        // ---------- remise a zero ----------
        $display("");
        $display("-- remise a zero --");
        @(posedge clk); #1;
        verifier("apres reset       ", 32'h0000_0000);

        // ---------- avancee normale ----------
        $display("");
        $display("-- avancee normale, 4 octets par instruction --");
        rst = 1'b0;

        pc_next = 32'h0000_0004;
        @(posedge clk); #1;
        verifier("pc_next = 4       ", 32'h0000_0004);

        pc_next = 32'h0000_0008;
        @(posedge clk); #1;
        verifier("pc_next = 8       ", 32'h0000_0008);

        pc_next = 32'h0000_000C;
        @(posedge clk); #1;
        verifier("pc_next = C       ", 32'h0000_000C);

        // ---------- branchement arriere ----------
        $display("");
        $display("-- branchement : saut arriere --");
        pc_next = 32'h0000_0004;
        @(posedge clk); #1;
        verifier("retour en arriere ", 32'h0000_0004);

        // ---------- valeur extreme ----------
        $display("");
        $display("-- adresse haute --");
        pc_next = 32'hFFFF_FFFC;
        @(posedge clk); #1;
        verifier("pc_next = fffffffc", 32'hFFFF_FFFC);

        // ---------- maintien hors front ----------
        $display("");
        $display("-- le pc ne bouge pas entre deux fronts --");
        pc_next = 32'h1234_5678;
        #2;
        verifier("avant le front    ", 32'hFFFF_FFFC);
        @(posedge clk); #1;
        verifier("apres le front    ", 32'h1234_5678);

        // ---------- priorite du reset ----------
        $display("");
        $display("-- le reset l'emporte sur pc_next --");
        rst     = 1'b1;
        pc_next = 32'hAAAA_AAAA;
        @(posedge clk); #1;
        verifier("reset + pc_next   ", 32'h0000_0000);

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
