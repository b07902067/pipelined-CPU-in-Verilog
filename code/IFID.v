module IFID
(
    clk_i,
    PC_i,
    Stall_i,
    Flush_i,
    Inst_i,
    PC_o,
    Inst_o
);

input           clk_i, Stall_i, Flush_i;
input   [31:0]  PC_i, Inst_i;


output  [31:0]  PC_o, Inst_o;

reg     [31:0]  PC_o, Inst_o;

initial begin
    PC_o = 0;
    Inst_o = 0;
end

always@(posedge clk_i) begin
    if(Flush_i) begin
        Inst_o <= 32'b0;
        PC_o <= PC_i;
    end
    else if(Stall_i  == 1'b0) begin
        Inst_o <= Inst_i;
        PC_o <= PC_i;
    end
end

endmodule
