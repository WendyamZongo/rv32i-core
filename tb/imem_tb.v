`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 03:29:42 PM
// Design Name: 
// Module Name: imem_tb
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
module imem_tb;

    reg  [31:0] addr;
    wire [31:0] inst;

    integer erreurs;

    imem dut (
        .addr (addr),
        .inst (inst)
    );

    //-----------------------------------------------------------------
    task verifier;
        input [159:0] nom;        // 20 caracteres
        input [31:0]  vaddr;
        input [31:0]  attendu;
        begin
            addr = vaddr;
            #10;
            if (inst === attendu)
                $display("  OK     %0s  addr=%0d  ->  %h", nom, vaddr, inst);
            else begin
                $display("  ECHEC  %0s  addr=%0d  ->  %h   attendu %h",
                         nom, vaddr, inst, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test imem");
        $display("=============================================");

        // ---------- le programme est-il charge ? ----------
        $display("");
        $display("-- lecture des huit instructions --");
        verifier("addi x5, x0, 10   ", 32'd0,  32'h00A0_0293);
        verifier("addi x6, x0, 3    ", 32'd4,  32'h0030_0313);
        verifier("add  x7, x5, x6   ", 32'd8,  32'h0062_83B3);
        verifier("sub  x8, x5, x6   ", 32'd12, 32'h4062_8433);
        verifier("and  x9, x5, x6   ", 32'd16, 32'h0062_F4B3);
        verifier("or   x10, x5, x6  ", 32'd20, 32'h0062_E533);
        verifier("xor  x11, x5, x6  ", 32'd24, 32'h0062_C5B3);
        verifier("addi x12, x7, -1  ", 32'd28, 32'hFFF3_8613);

        // ---------- les deux bits bas sont ignores ----------
        $display("");
        $display("-- addr[1:0] ne doit rien changer --");
        verifier("addr = 8          ", 32'd8,  32'h0062_83B3);
        verifier("addr = 9          ", 32'd9,  32'h0062_83B3);
        verifier("addr = 10         ", 32'd10, 32'h0062_83B3);
        verifier("addr = 11         ", 32'd11, 32'h0062_83B3);
        verifier("addr = 12 (suivant)", 32'd12, 32'h4062_8433);

        // ---------- au-dela du programme ----------
        $display("");
        $display("-- au-dela de la 8e instruction : memoire vide --");
        addr = 32'd32;
        #10;
        if (inst === 32'hxxxx_xxxx)
            $display("  OK     mem[8] non initialisee  ->  xxxxxxxx");
        else
            $display("  INFO   mem[8] = %h", inst);

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
