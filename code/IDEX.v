module IDEX
(
    clk_i, 
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    Reg1_i,
    Reg2_i,
    Imm_i,
    funct_i,
    Rs1_i,
    Rs2_i,
    Rd_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Reg1_o,
    Reg2_o,
    Imm_o,
    funct_o,
    Rs1_o,
    Rs2_o,
    Rd_o
);

input           clk_i;
input           RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i, ALUSrc_i;
input   [1:0]   ALUOp_i; 
input   [31:0]  Reg1_i, Reg2_i, Imm_i;
input   [9:0]   funct_i;
input   [4:0]   Rs1_i, Rs2_i, Rd_i;

output           RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUSrc_o;
output   [1:0]   ALUOp_o; 
output   [31:0]  Reg1_o, Reg2_o, Imm_o;
output   [9:0]   funct_o;
output   [4:0]   Rs1_o, Rs2_o, Rd_o;

reg              RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUSrc_o;
reg      [1:0]   ALUOp_o; 
reg      [31:0]  Reg1_o, Reg2_o, Imm_o;
reg      [9:0]   funct_o;
reg      [4:0]   Rs1_o, Rs2_o, Rd_o;


initial begin
    RegWrite_o = 1'b0;
    MemtoReg_o = 1'b0;
    MemRead_o = 1'b0;
    MemWrite_o = 1'b0;
    ALUOp_o = 2'b0;
    ALUSrc_o = 1'b0;
    Reg1_o = 32'b0;
    Reg2_o = 32'b0;
    Imm_o = 32'b0;
    funct_o = 10'b0;
    Rs1_o = 5'b0;
    Rs2_o = 5'b0;
    Rd_o = 5'b0;
end

always@(posedge clk_i) begin
    RegWrite_o <= RegWrite_i;
    MemtoReg_o <= MemtoReg_i;
    MemRead_o <= MemRead_i;
    MemWrite_o <= MemWrite_i;
    ALUOp_o <= ALUOp_i;
    ALUSrc_o <= ALUSrc_i;
    Reg1_o <= Reg1_i;
    Reg2_o <= Reg2_i;
    Imm_o <= Imm_i;
    funct_o <= funct_i;
    Rs1_o <= Rs1_i;
    Rs2_o <= Rs2_i;
    Rd_o <= Rd_i;
end

endmodule