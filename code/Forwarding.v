module FORWARD
(
    Rs1_i,
    Rs2_i,
    MEMRd_i,
    MEMRegWrite_i,
    WBRd_i,
    WBRegWrite_i,
    Forward1_o,
    Forward2_o
);

input   [4:0]   Rs1_i, Rs2_i, MEMRd_i, WBRd_i;
input           MEMRegWrite_i, WBRegWrite_i;

output  [1:0]   Forward1_o, Forward2_o;

assign Forward1_o = (Rs1_i == MEMRd_i && MEMRegWrite_i == 1'b1)? 2'b10 :
                    (Rs1_i == WBRd_i && WBRegWrite_i == 1'b1)? 2'b01 : 2'b00;
assign Forward2_o = (Rs2_i == MEMRd_i && MEMRegWrite_i == 1'b1)? 2'b10 :
                    (Rs2_i == WBRd_i && WBRegWrite_i == 1'b1)? 2'b01 : 2'b00;

endmodule