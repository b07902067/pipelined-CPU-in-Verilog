module MEMWB
(
    clk_i,
    RegWrite_i,
    MemtoReg_i,
    ALUResult_i,
    Rd_i,
    DATARd_i,
    RegWrite_o,
    MemtoReg_o,
    ALUResult_o,
    Rd_o,
    DATARd_o,
);

input           clk_i;
input           RegWrite_i, MemtoReg_i;
input   [31:0]  ALUResult_i, DATARd_i;
input   [4:0]   Rd_i;

output          RegWrite_o, MemtoReg_o;
output   [31:0] ALUResult_o, DATARd_o;
output   [4:0]  Rd_o;

reg             RegWrite_o, MemtoReg_o;
reg      [31:0] ALUResult_o, DATARd_o;
reg      [4:0]  Rd_o;


initial begin
    RegWrite_o = 1'b0;
    MemtoReg_o = 1'b0;
    ALUResult_o = 1'b0;
    Rd_o = 5'b0;
    DATARd_o = 32'b0;
end


always@(posedge clk_i) begin
    RegWrite_o <= RegWrite_i;
    MemtoReg_o <= MemtoReg_i;
    ALUResult_o <= ALUResult_i;
    Rd_o <= Rd_i;
    DATARd_o <= DATARd_i;
end

endmodule
