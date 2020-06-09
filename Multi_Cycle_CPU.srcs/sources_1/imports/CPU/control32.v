module control32(
    Opcode,
    Function_opcode,
    Alu_resultHigh,
    Jrn,RegDST,
    ALUSrc,
    MemorIOtoReg,
    RegWrite,
    MemRead,
    MemWrite,
    IORead,
    IOWrite,
    Branch,
    nBranch,
    Jmp,
    Jal,
    I_format,
    Sftmd,
    ALUOp,
    Wpc,
    Wir,
    Waluresult,
    Zero,
    clock,
    reset
);
    input[5:0] Opcode;
    input[5:0] Function_opcode;
    input[21:0] Alu_resultHigh;
    input   clock;
    input   reset;
    input   Zero;

    output Jrn;
    output RegDST;
    output ALUSrc;
    output MemorIOtoReg;
    output RegWrite;
    output MemRead;
    output MemWrite;
    output IORead;
    output IOWrite;
    output Branch;
    output nBranch;
    output Jmp;
    output Jal;
    output I_format;
    output Sftmd;
    output[1:0] ALUOp;
    output[1:0] Wpc;
    output Wir;
    output Waluresult;

    wire R_format;
    wire Lw;		
    wire Sw;	
    reg[2:0]    next_state;
    reg[2:0]    state;
    parameter[2:0] sinit = 3'b000, sif = 3'b001, sid = 3'b010, sexe = 3'b011, smem = 3'b100, swb = 101;	
   
    assign R_format = (Opcode==6'b000000) ? 1'b1:1'b0;    
    assign RegDST = ((R_format == 1) && (state == swb)) ? 1'b1 : 1'b0;                            
    assign I_format = (Opcode[5:3]==3'b001) ? 1'b1: 1'b0;
    assign Lw = (Opcode==6'b100011) ? 1'b1:1'b0;
    assign Jal = (Opcode==6'b000011) ? 1'b1:1'b0;
    assign Jrn = (R_format==1'b1 & Function_opcode==6'b001000)? 1'b1:1'b0;   
    assign RegWrite = (((state == sid) && (Jal == 1)) || (state == swb)) ? 1'b1 : 1'b0;
    assign Sw = (Opcode==6'b101011) ? 1'b1:1'b0;
    assign ALUSrc = I_format | Lw | Sw;
    assign Branch = (Opcode==6'b000100) ? 1'b1:1'b0;
    assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;
    assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;
    assign MemWrite = ((Sw == 1 && state == smem) && (Alu_resultHigh!=22'b1111111111111111111111))?1'b1:1'b0;
    assign MemorIOtoReg = ((Lw==1) && (state == swb)) ? 1'b1:1'b0;
	assign MemRead = ((Lw==1) && (Alu_resultHigh!=22'b1111111111111111111111))?1'b1:1'b0;
	assign IOWrite = ((state == smem) && (Alu_resultHigh==22'b1111111111111111111111))?1'b1:1'b0;
	assign IORead = ((Lw==1) && (Alu_resultHigh==22'b1111111111111111111111))?1'b1:1'b0;
    assign Sftmd = (Lw == 1) ? 0 : (Function_opcode[5:3]==3'b000)? 1'b1: 1'b0;
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
    assign Wir = (state == sif) ? 1'b1 : 1'b0;
    assign Waluresult = (state == sexe) ? 1'b1 : 1'b0;
    assign Wpc = (state == sif) ? 2'b01 : ((state == sid) && (Jmp || Jal || Jrn) ? 2'b10 : ((state == sexe) && ((Branch && Zero) || (nBranch && !Zero)) ? 2'b11 : 2'b00));



    always@(posedge clock or posedge reset) begin
        if(reset) 
            state <= sinit;
        else 
            state <= next_state;
    end 

    always@* begin
        case (state)
            sinit : next_state = sif;
            sif : next_state = sid;
            sid : begin
                if(Jmp || Jrn || Jal) 
                    next_state = sif;
                else 
                    next_state = sexe;
            end
            sexe : begin
                if(Lw || Sw)
                    next_state = smem;
                else if(Branch || nBranch)
                    next_state = sif;
                else
                    next_state = swb;
            end
            smem : begin
                if(Lw)
                    next_state = swb;
                else
                    next_state = sif;
            end
            swb: next_state = sif;
            default : next_state = sif; 
        endcase
    end

endmodule