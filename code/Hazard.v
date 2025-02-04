module HAZARD
(
    Rs1_i,
    Rs2_i,
    EXRd_i,
    ID_EXRead_i,
    Stall_o,
    PCWrite_o,
    NoOp_o
);

input   [4:0]   Rs1_i, Rs2_i, EXRd_i;
input           ID_EXRead_i;

output          Stall_o, PCWrite_o, NoOp_o;

assign Stall_o = (Rs1_i && Rs2_i && EXRd_i && (Rs1_i == EXRd_i || Rs2_i == EXRd_i) && ID_EXRead_i == 1'b1 )? 1'b1 : 1'b0;
assign PCWrite_o = (Rs1_i && Rs2_i  && EXRd_i && (Rs1_i == EXRd_i || Rs2_i == EXRd_i) && ID_EXRead_i == 1'b1 )? 1'b0 : 1'b1;
assign NoOp_o = (Rs1_i && Rs2_i && EXRd_i &&(Rs1_i == EXRd_i || Rs2_i == EXRd_i) && ID_EXRead_i == 1'b1 )? 1'b1 : 1'b0;

endmodule
