`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 05:13:58 PM
// Design Name: 
// Module Name: Core
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
module core (
    input wire clk,
    input wire rst,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_result
);

    //-----------------------------------------------------------------
    //  Fils du chemin de donnees
    //-----------------------------------------------------------------
    wire [31:0] pc_current, pc_next, pc_plus4, pc_plus_imm;
    wire [31:0] inst;
    wire [31:0] imm;
    wire [31:0] rs1_data, rs2_data, rd_data;
    wire [31:0] alu_a, alu_b, alu_result;
    wire [31:0] dmem_rdata;
    wire        zero, br_taken;

    //-----------------------------------------------------------------
    //  Signaux de controle
    //-----------------------------------------------------------------
    wire        reg_write, alu_src_b, read_mem, write_mem, branch, jump;
    wire [2:0]  im_src;
    wire [1:0]  alu_src_a, wb_sel, alu_op;
    wire [3:0]  alu_ctl;

    //-----------------------------------------------------------------
    //  Champs extraits de l'instruction
    //-----------------------------------------------------------------
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire       inst30 = inst[30];
    wire [4:0] rs1_a  = inst[19:15];
    wire [4:0] rs2_a  = inst[24:20];
    wire [4:0] rd_a   = inst[11:7];

    //=================================================================
    //  Compteur de programme
    //=================================================================
    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc_current)
    );

    assign pc_plus4    = pc_current + 32'd4;
    assign pc_plus_imm = pc_current + imm;

    //=================================================================
    //  Memoire d'instructions
    //=================================================================
    imem u_imem (
        .addr (pc_current),
        .inst (inst)
    );

    //=================================================================
    //  Decodage
    //=================================================================
    control u_control (
        .opcode    (opcode),
        .im_src    (im_src),
        .alu_src_a (alu_src_a),
        .alu_op    (alu_op),
        .wb_sel    (wb_sel),
        .write_mem (write_mem),
        .read_mem  (read_mem),
        .jump      (jump),
        .branch    (branch),
        .alu_src_b (alu_src_b),
        .reg_write (reg_write)
    );

    aluControl u_alu_control (
        .alu_op  (alu_op),
        .fnct    (funct3),
        .op_5    (opcode[5]),
        .inst    (inst30),
        .alu_ctl (alu_ctl)
    );

    imGen u_imgen (
        .inst   (inst),
        .im_src (im_src),
        .imm    (imm)
    );

    //=================================================================
    //  Banc de registres
    //=================================================================
    regFile u_regfile (
        .clk      (clk),
        .we       (reg_write),
        .rs1_add  (rs1_a),
        .rs2_add  (rs2_a),
        .rd_add   (rd_a),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    //=================================================================
    //  Multiplexeur 1 : entree A de l'ALU
    //     00 = rs1_data     01 = PC     10 = zero
    //=================================================================
    assign alu_a = (alu_src_a == 2'b01) ? pc_current :
                   (alu_src_a == 2'b10) ? 32'd0      :
                                          rs1_data;

    //=================================================================
    //  Multiplexeur 2 : entree B de l'ALU
    //     0 = rs2_data      1 = immediat
    //=================================================================
    assign alu_b = alu_src_b ? imm : rs2_data;

    //=================================================================
    //  ALU
    //=================================================================
    alu u_alu (
        .a       (alu_a),
        .b       (alu_b),
        .alu_ctl (alu_ctl),
        .rsult   (alu_result),
        .zero    (zero)
    );

    //=================================================================
    //  Memoire de donnees
    //     adresse = resultat de l'ALU (rs1 + imm)
    //     donnee  = rs2_data, directement
    //=================================================================
    dmem u_dmem (
        .clk   (clk),
        .we    (write_mem),
        .addr  (alu_result),
        .wdata (rs2_data),
        .rdata (dmem_rdata)
    );

    //=================================================================
    //  Decision de branchement
    //=================================================================
    branch_unit u_branch (
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .funct3   (funct3),
        .taken    (br_taken)
    );

    //=================================================================
    //  Multiplexeur 3 : ecriture dans rd
    //     00 = resultat ALU   01 = memoire   10 = PC + 4
    //=================================================================
    assign rd_data = (wb_sel == 2'b01) ? dmem_rdata :
                     (wb_sel == 2'b10) ? pc_plus4   :
                                         alu_result;

    //=================================================================
    //  Multiplexeur 4 : adresse suivante
    //
    //  jal  : l'ALU calcule PC + imm   (alu_src_a = 01)
    //  jalr : l'ALU calcule rs1 + imm  (alu_src_a = 00)
    //  Dans les deux cas la cible est le resultat de l'ALU.
    //  Le bit 0 est force a zero, comme l'exige jalr.
    //=================================================================
    assign pc_next = jump                 ? {alu_result[31:1], 1'b0} :
                     (branch && br_taken) ? pc_plus_imm              :
                                            pc_plus4;
    assign debug_pc     = pc_current;
    assign debug_result = alu_result;

endmodule
