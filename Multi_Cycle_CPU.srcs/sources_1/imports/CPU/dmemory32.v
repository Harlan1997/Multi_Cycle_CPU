`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 17:36:17
// Design Name: 
// Module Name: dmemory32
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


module dmemory32(
    input clock,
    input [31:0] address,
    input [31:0] write_data,
    input MemWrite,
    output [31:0] read_data
    );
    //Generating a clk signal, which is the inverted clock of the clock signal 
    //Create a instance of RAM(IP core),binding the ports 
    assign clk = clock; 
    wire[31:0]  douta;
    RAM ram ( 
    .clka(clk), // input wire clka 
    .clkb(clk),
    .wea(MemWrite), // input wire [0 : 0] wea 
    .addra(address[15:2]), // input wire [13 : 0] addra 
    .addrb(address[15:2]),
    .dina(write_data), // input wire [31 : 0] dina 
    .douta(read_data),
    .doutb(douta) // output wire [31 : 0] douta 
    );
endmodule
