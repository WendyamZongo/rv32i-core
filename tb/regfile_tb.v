`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 03:49:39 PM
// Design Name: 
// Module Name: regfile_tb
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
//  Banc de test pour regFile
//
//  Vérifie :
//    - écriture puis relecture
//    - x0 reste à zéro, même après tentative d'écriture
//    - we = 0 bloque bien l'écriture
//    - les deux ports de lecture fonctionnent simultanément
//    - réécriture d'un registre déjà occupé
//=====================================================================

module regfile_tb;

    reg         clk;
    reg         we;
    reg  [4:0]  rs1_add;
    reg  [4:0]  rs2_add;
    reg  [4:0]  rd_add;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    integer erreurs;

    regFile dut (
        .clk      (clk),
        .we       (we),
        .rs1_add  (rs1_add),
        .rs2_add  (rs2_add),
        .rd_add   (rd_add),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // horloge : période de 10 ns
    always #5 clk = ~clk;

    //-----------------------------------------------------------------
    //  ecrire : place une valeur dans un registre au front d'horloge
    //-----------------------------------------------------------------
    task ecrire;
        input [4:0]  num;
        input [31:0] val;
        begin
            @(negedge clk);
            rd_add  = num;
            rd_data = val;
            we      = 1'b1;
            @(posedge clk);
            @(negedge clk);
            we      = 1'b0;
        end
    endtask

    //-----------------------------------------------------------------
    //  ecrire_sans_we : tente une écriture avec we à 0
    //-----------------------------------------------------------------
    task ecrire_sans_we;
        input [4:0]  num;
        input [31:0] val;
        begin
            @(negedge clk);
            rd_add  = num;
            rd_data = val;
            we      = 1'b0;
            @(posedge clk);
            @(negedge clk);
        end
    endtask

    //-----------------------------------------------------------------
    //  verif_port1 : lit un registre par le port 1 et compare
    //-----------------------------------------------------------------
    task verif_port1;
        input [4:0]  num;
        input [31:0] attendu;
        begin
            rs1_add = num;
            #1;
            if (rs1_data === attendu)
                $display("  OK     port1  x%0d = %h", num, rs1_data);
            else begin
                $display("  ECHEC  port1  x%0d = %h   attendu %h",
                         num, rs1_data, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    //  verif_port2 : idem par le port 2
    //-----------------------------------------------------------------
    task verif_port2;
        input [4:0]  num;
        input [31:0] attendu;
        begin
            rs2_add = num;
            #1;
            if (rs2_data === attendu)
                $display("  OK     port2  x%0d = %h", num, rs2_data);
            else begin
                $display("  ECHEC  port2  x%0d = %h   attendu %h",
                         num, rs2_data, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        clk     = 1'b0;
        we      = 1'b0;
        rs1_add = 5'd0;
        rs2_add = 5'd0;
        rd_add  = 5'd0;
        rd_data = 32'd0;
        erreurs = 0;

        $display("");
        $display("=============================================");
        $display("  Banc de test regFile");
        $display("=============================================");

        // ---------- écriture puis relecture ----------
        $display("");
        $display("-- ecriture puis relecture --");
        ecrire(5'd5,  32'hDEAD_BEEF);
        verif_port1(5'd5, 32'hDEAD_BEEF);

        ecrire(5'd17, 32'h1234_5678);
        verif_port1(5'd17, 32'h1234_5678);

        ecrire(5'd31, 32'hFFFF_FFFF);
        verif_port1(5'd31, 32'hFFFF_FFFF);

        // ---------- les deux ports en parallele ----------
        $display("");
        $display("-- deux lectures simultanees --");
        rs1_add = 5'd5;
        rs2_add = 5'd17;
        #1;
        verif_port1(5'd5,  32'hDEAD_BEEF);
        verif_port2(5'd17, 32'h1234_5678);

        // ---------- x0 ----------
        $display("");
        $display("-- x0 reste a zero --");
        verif_port1(5'd0, 32'h0000_0000);
        verif_port2(5'd0, 32'h0000_0000);

        ecrire(5'd0, 32'hAAAA_AAAA);      // tentative d'ecriture dans x0
        verif_port1(5'd0, 32'h0000_0000);
        verif_port2(5'd0, 32'h0000_0000);

        // ---------- we = 0 bloque l'ecriture ----------
        $display("");
        $display("-- we = 0 bloque l'ecriture --");
        ecrire_sans_we(5'd5, 32'h0000_0001);
        verif_port1(5'd5, 32'hDEAD_BEEF);   // valeur inchangee

        // ---------- reecriture ----------
        $display("");
        $display("-- reecriture d'un registre occupe --");
        ecrire(5'd5, 32'hCAFE_0000);
        verif_port1(5'd5, 32'hCAFE_0000);
        verif_port1(5'd17, 32'h1234_5678);  // les voisins n'ont pas bouge
        verif_port1(5'd31, 32'hFFFF_FFFF);

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
