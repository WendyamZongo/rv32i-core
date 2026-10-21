`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 04:18:52 PM
// Design Name: 
// Module Name: dem_tb
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
//  Banc de test pour dmem
//
//  Verifie l'ecriture puis la relecture, le blocage par we = 0,
//  la division par quatre, et l'independance des cases.
//=====================================================================

module dmem_tb;

    reg         clk;
    reg         we;
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;

    integer erreurs;

    dmem dut (
        .clk   (clk),
        .we    (we),
        .addr  (addr),
        .wdata (wdata),
        .rdata (rdata)
    );

    always #5 clk = ~clk;

    //-----------------------------------------------------------------
    task ecrire;
        input [31:0] a;
        input [31:0] d;
        begin
            @(negedge clk);
            addr  = a;
            wdata = d;
            we    = 1'b1;
            @(posedge clk);
            @(negedge clk);
            we    = 1'b0;
        end
    endtask

    task ecrire_sans_we;
        input [31:0] a;
        input [31:0] d;
        begin
            @(negedge clk);
            addr  = a;
            wdata = d;
            we    = 1'b0;
            @(posedge clk);
            @(negedge clk);
        end
    endtask

    task verifier;
        input [151:0] nom;        // 19 caracteres
        input [31:0]  a;
        input [31:0]  attendu;
        begin
            addr = a;
            #1;
            if (rdata === attendu)
                $display("  OK     %0s  addr=%0d  ->  %h", nom, a, rdata);
            else begin
                $display("  ECHEC  %0s  addr=%0d  ->  %h   attendu %h",
                         nom, a, rdata, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        clk     = 1'b0;
        we      = 1'b0;
        addr    = 32'd0;
        wdata   = 32'd0;
        erreurs = 0;

        $display("");
        $display("=============================================");
        $display("  Banc de test dmem");
        $display("=============================================");

        // ---------- ecriture puis relecture ----------
        $display("");
        $display("-- ecriture puis relecture --");
        ecrire(32'd0,   32'hDEAD_BEEF);
        verifier("addr 0            ", 32'd0,   32'hDEAD_BEEF);

        ecrire(32'd4,   32'h1234_5678);
        verifier("addr 4            ", 32'd4,   32'h1234_5678);

        ecrire(32'd1020, 32'hFFFF_FFFF);          // derniere case : mem[255]
        verifier("addr 1020         ", 32'd1020, 32'hFFFF_FFFF);

        // ---------- les cases sont independantes ----------
        $display("");
        $display("-- les voisines n'ont pas bouge --");
        verifier("addr 0 inchange   ", 32'd0, 32'hDEAD_BEEF);
        verifier("addr 4 inchange   ", 32'd4, 32'h1234_5678);

        // ---------- division par quatre ----------
        $display("");
        $display("-- addr[1:0] ne doit rien changer --");
        verifier("addr 4            ", 32'd4, 32'h1234_5678);
        verifier("addr 5            ", 32'd5, 32'h1234_5678);
        verifier("addr 6            ", 32'd6, 32'h1234_5678);
        verifier("addr 7            ", 32'd7, 32'h1234_5678);
        verifier("addr 8 (suivante) ", 32'd8, 32'hxxxx_xxxx);

        // ---------- we = 0 bloque l'ecriture ----------
        $display("");
        $display("-- we = 0 bloque l'ecriture --");
        ecrire_sans_we(32'd0, 32'h0000_0001);
        verifier("addr 0 preserve   ", 32'd0, 32'hDEAD_BEEF);

        // ---------- reecriture ----------
        $display("");
        $display("-- reecriture d'une case occupee --");
        ecrire(32'd0, 32'hCAFE_0000);
        verifier("addr 0 ecrase     ", 32'd0,   32'hCAFE_0000);
        verifier("addr 4 intact     ", 32'd4,   32'h1234_5678);
        verifier("addr 1020 intact  ", 32'd1020, 32'hFFFF_FFFF);

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
