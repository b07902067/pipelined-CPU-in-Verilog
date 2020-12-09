module EXMEM
(
    clk_i, 
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    Rd_i,
    ALUResult_i,
    Reg2_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Rd_o,
    ALUResult_o,
    DATAWr_o,
);

input           clk_i;
input           RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i;
input   [4:0]   Rd_i;
input   [31:0]  ALUResult_i, Reg2_i;

output           RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
output   [4:0]   Rd_o;
output   [31:0]  ALUResult_o , DATAWr_o;

reg              RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
reg      [4:0]   Rd_o;
reg      [31:0]  ALUResult_o , DATAWr_o;

initial begin
    RegWrite_o = 1'b0;
    MemtoReg_o = 1'b0;
    MemRead_o = 1'b0;
    MemWrite_o = 1'b0;
    Rd_o = 5'b0;
    ALUResult_o = 32'b0;
    DATAWr_o = 32'b0;
end

always@(posedge clk_i) begin
    RegWrite_o <= RegWrite_i;
    MemtoReg_o <= MemtoReg_i;
    MemRead_o <= MemRead_i;
    MemWrite_o <= MemWrite_i;
    Rd_o <= Rd_i;
    ALUResult_o <= ALUResult_i;
    DATAWr_o <= Reg2_i;
end

endmodule
