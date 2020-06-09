`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 23:48:52
// Design Name: 
// Module Name: Ifetc32
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


module Ifetc32(
    Instruction,
    PC_plus_4_out,
    Add_result,
    Read_data_1,
    Jmp,
    Jal,
    clock,
    reset, 
    opcplus4,
    Wpc,
    Wir
    );
    output[31:0] Instruction; // the instruction fetched from this module    
    output[31:0] PC_plus_4_out;          // (pc+4) to ALU which is used by branch type instruction   
    input[31:0]  Add_result;                  // from ALU module，the calculated address     
    input[31:0]  Read_data_1;               // from decoder，the address of instruction used by jr instruction    
 
    input        Jmp;                   // from controller, while Jmp 1,it means current instruction is jump     
    input        Jal;                   // from controller, while Jal is 1,it means current instruction is jal    
    input        clock,reset;           // Clock and reset    
    output[31:0] opcplus4;              // (pc+4) to  decoder which is used by jal instruction
    input[1:0] Wpc;
    input   Wir;
    reg[31:0]   PC;
    reg[31:0]   IR;
    wire[31:0]  Instruction;
    wire[31:0]  instruction;
    reg[31:0] opcplus4;
    assign PC_plus_4_out = PC;
    prgrom instm(
            .clka(clock),
            .addra(PC[15:2]),
            .douta(instruction)
        );
    assign Instruction = IR;
    always@(negedge clock) begin
        if(reset)
            IR <= 32'b0;
        else if(Wir)
            IR <= instruction;
        else    
            IR <= IR;
    end
    
    reg[31:0] previous_PC;
    always@(negedge clock) begin
        if (reset)
            PC = 32'b0;
        else begin
            previous_PC = PC;
            case(Wpc)
                2'b01 : PC = PC + 4;
                2'b11 : PC = Add_result;
                2'b10 : begin
                    if(Jmp)
                        PC = Instruction[25:0] << 2;
                    else if(Jal) begin
                        PC = Instruction[25:0] << 2;
                        opcplus4 = previous_PC; // the previous PC has been added 4
                    end
                    else
                        PC = Read_data_1;
                end
            endcase
        end 
    end
   /*
    always @(negedge clock) begin
        if (reset)
            begin
                PC = 32'd0;
            end
        else
        begin
            if (Jmp==1'b1)
                begin
                    PC = Instruction[25:0]<<2;
                end
            else if (Jal==1'b1)
                begin
                    opcplus4 = PC_plus_4;
                    PC = Instruction[25:0]<<2;
                end
            else
                begin
                    PC = next_PC;
                end
        end
   end
   */
endmodule