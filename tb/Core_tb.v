`timescale 1ns / 1ps

//=====================================================================
//  Banc de test pour core - programme a boucle
//
//  Le programme calcule 1+2+3+4+5 dans une boucle, range le resultat
//  en memoire, le relit, puis se bloque sur un saut sur place.
//
//      0   addi x1, x0, 0       somme = 0
//      4   addi x2, x0, 1       i = 1
//      8   addi x3, x0, 6       limite = 6
//     12   beq  x2, x3, 28      si i == 6, sortir
//     16   add  x1, x1, x2      somme += i
//     20   addi x2, x2, 1       i++
//     24   jal  x0, -12         recommencer
//     28   sw   x1, 0(x0)       mem[0] = somme
//     32   lw   x4, 0(x0)       x4 = mem[0]
//     36   addi x5, x0, 99      marqueur de fin
//     40   jal  x0, 0           halt
//
//  Il exerce : addi, add, beq non pris, beq pris, jal arriere,
//              sw, lw, et le blocage final.
//=====================================================================

module core_tb;

    reg clk;
    reg rst;

    integer erreurs;
    integer c;

    core dut (
        .clk (clk),
        .rst (rst)
    );

    always #5 clk = ~clk;

    //-----------------------------------------------------------------
    task verif_reg;
        input integer num;
        input [31:0]  attendu;
        reg   [31:0]  valeur;
        begin
            valeur = dut.u_regfile.regs[num];
            if (valeur === attendu)
                $display("  OK     x%0d = %0d", num, $signed(valeur));
            else begin
                $display("  ECHEC  x%0d = %0d   attendu %0d",
                         num, $signed(valeur), $signed(attendu));
                erreurs = erreurs + 1;
            end
        end
    endtask

    task verif_mem;
        input integer num;
        input [31:0]  attendu;
        reg   [31:0]  valeur;
        begin
            valeur = dut.u_dmem.mem[num];
            if (valeur === attendu)
                $display("  OK     mem[%0d] = %0d", num, $signed(valeur));
            else begin
                $display("  ECHEC  mem[%0d] = %0d   attendu %0d",
                         num, $signed(valeur), $signed(attendu));
                erreurs = erreurs + 1;
            end
        end
    endtask

    task verif_pc;
        input [31:0] attendu;
        begin
            if (dut.pc_current === attendu)
                $display("  OK     PC = %0d  (bloque sur le halt)", dut.pc_current);
            else begin
                $display("  ECHEC  PC = %0d   attendu %0d", dut.pc_current, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        erreurs = 0;

        $display("");
        $display("=============================================");
        $display("  Banc de test core : somme de 1 a 5");
        $display("=============================================");

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // ---------- trace ----------
        $display("");
        $display("-- trace de l'execution --");
        $display("  cyc   PC  instruction   x1  x2  x3  x4  x5   mem[0]");

        for (c = 0; c < 30; c = c + 1) begin
            #1;
            $display("  %3d %4d  %h   %3d %3d %3d %3d %3d   %0d",
                     c, dut.pc_current, dut.inst,
                     dut.u_regfile.regs[1], dut.u_regfile.regs[2],
                     dut.u_regfile.regs[3], dut.u_regfile.regs[4],
                     dut.u_regfile.regs[5], dut.u_dmem.mem[0]);
            @(posedge clk);
            @(negedge clk);
        end

        // ---------- etat final ----------
        #1;
        $display("");
        $display("-- etat final --");
        verif_reg(1,  32'd15);    // 1+2+3+4+5
        verif_reg(2,  32'd6);     // le compteur a atteint la limite
        verif_reg(3,  32'd6);     // la limite, inchangee
        verif_reg(4,  32'd15);    // relu depuis la memoire
        verif_reg(5,  32'd99);    // marqueur de fin
        verif_mem(0,  32'd15);    // la somme rangee en memoire
        verif_pc (32'd40);        // bloque sur le saut sur place

        // ---------- verdict ----------
        $display("");
        $display("=============================================");
        if (erreurs == 0)
            $display("  RESULTAT : boucle, branchements et memoire fonctionnent");
        else
            $display("  RESULTAT : %0d erreur(s)", erreurs);
        $display("=============================================");
        $display("");
        $finish;
    end

endmodule