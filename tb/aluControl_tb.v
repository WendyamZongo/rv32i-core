`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 04:12:24 PM
// Design Name: 
// Module Name: aluControl_tb
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
module alu_control_tb;

    reg  [1:0] alu_op;
    reg  [2:0] funct3;
    reg        inst30;
    reg        op5;
    wire [3:0] alu_ctl;

    integer erreurs;

    localparam ADD  = 4'b0000, SUB  = 4'b0001, AND_ = 4'b0010, OR_  = 4'b0011;
    localparam XOR_ = 4'b0100, SLL  = 4'b0101, SRL  = 4'b0110, SRA  = 4'b0111;
    localparam SLT  = 4'b1000, SLTU = 4'b1001;

    aluControl dut (
        .alu_op  (alu_op),
        .fnct    (funct3),
        .inst    (inst30),
        .op_5    (op5),
        .alu_ctl (alu_ctl)
    );

    //-----------------------------------------------------------------
    task verifier;
        input [71:0] nom;          // 9 caracteres
        input [1:0]  vop;
        input [2:0]  vf3;
        input        v30;
        input        v5;
        input [3:0]  attendu;
        begin
            alu_op = vop;  funct3 = vf3;  inst30 = v30;  op5 = v5;
            #10;
            if (alu_ctl === attendu)
                $display("  OK     %0s  op=%b f3=%b i30=%b o5=%b  ->  %b",
                         nom, vop, vf3, v30, v5, alu_ctl);
            else begin
                $display("  ECHEC  %0s  op=%b f3=%b i30=%b o5=%b  ->  %b   attendu %b",
                         nom, vop, vf3, v30, v5, alu_ctl, attendu);
                erreurs = erreurs + 1;
            end
        end
    endtask

    //-----------------------------------------------------------------
    initial begin
        erreurs = 0;
        $display("");
        $display("=============================================");
        $display("  Banc de test alu_control");
        $display("=============================================");

        // ---------- alu_op impose l'operation ----------
        $display("");
        $display("-- alu_op = 00 : addition forcee (lw, sw, jal, lui, auipc) --");
        verifier("lw       ", 2'b00, 3'b010, 1'b0, 1'b0, ADD);
        verifier("sw       ", 2'b00, 3'b010, 1'b0, 1'b0, ADD);
        verifier("lui      ", 2'b00, 3'b000, 1'b1, 1'b1, ADD);  // i30 ignore

        $display("");
        $display("-- alu_op = 01 : soustraction forcee (branchements) --");
        verifier("beq      ", 2'b01, 3'b000, 1'b0, 1'b0, SUB);
        verifier("blt      ", 2'b01, 3'b100, 1'b1, 1'b1, SUB);  // i30 ignore

        // ---------- type R ----------
        $display("");
        $display("-- alu_op = 10, type R (op5 = 1) --");
        verifier("add      ", 2'b10, 3'b000, 1'b0, 1'b1, ADD);
        verifier("sub      ", 2'b10, 3'b000, 1'b1, 1'b1, SUB);
        verifier("sll      ", 2'b10, 3'b001, 1'b0, 1'b1, SLL);
        verifier("slt      ", 2'b10, 3'b010, 1'b0, 1'b1, SLT);
        verifier("sltu     ", 2'b10, 3'b011, 1'b0, 1'b1, SLTU);
        verifier("xor      ", 2'b10, 3'b100, 1'b0, 1'b1, XOR_);
        verifier("srl      ", 2'b10, 3'b101, 1'b0, 1'b1, SRL);
        verifier("sra      ", 2'b10, 3'b101, 1'b1, 1'b1, SRA);
        verifier("or       ", 2'b10, 3'b110, 1'b0, 1'b1, OR_);
        verifier("and      ", 2'b10, 3'b111, 1'b0, 1'b1, AND_);

        // ---------- type I ----------
        $display("");
        $display("-- alu_op = 10, type I (op5 = 0) --");
        verifier("addi     ", 2'b10, 3'b000, 1'b0, 1'b0, ADD);
        verifier("slti     ", 2'b10, 3'b010, 1'b0, 1'b0, SLT);
        verifier("sltiu    ", 2'b10, 3'b011, 1'b0, 1'b0, SLTU);
        verifier("xori     ", 2'b10, 3'b100, 1'b0, 1'b0, XOR_);
        verifier("ori      ", 2'b10, 3'b110, 1'b0, 1'b0, OR_);
        verifier("andi     ", 2'b10, 3'b111, 1'b0, 1'b0, AND_);
        verifier("slli     ", 2'b10, 3'b001, 1'b0, 1'b0, SLL);
        verifier("srli     ", 2'b10, 3'b101, 1'b0, 1'b0, SRL);
        verifier("srai     ", 2'b10, 3'b101, 1'b1, 1'b0, SRA);

        // ---------- LE PIEGE ----------
        $display("");
        $display("-- le piege : addi avec un immediat dont inst[30] vaut 1 --");
        $display("   (addi x5, x6, -1024  ->  imm = 110000000000)");
        verifier("addi neg ", 2'b10, 3'b000, 1'b1, 1'b0, ADD);   // DOIT rester add

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
