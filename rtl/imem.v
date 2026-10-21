`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 03:05:00 PM
// Design Name: 
// Module Name: imem
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


module imem(
input wire [31:0] addr,
output wire [31:0] inst
    );
    reg [31:0] mem [0:255];
    initial begin
    //  Program image.
    //
    //  Adapt this path to your own installation.
    //
    //  Under Vivado, programme.hex must be added as a DESIGN source,
    //  not only as a simulation source. If $readmemh fails during
    //  synthesis, imem reads as constant zero and the entire datapath
    //  is optimised away — the utilisation report then shows 1 LUT.
    // ---------------------------------------------------------------
     $readmemh ("C:/Users/pc/Documents/RTL/programme.hex",mem);
    end
     assign inst = mem [ addr [31:2]];
endmodule
