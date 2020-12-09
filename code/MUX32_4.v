module MUX32_4
(
    signal_i,
    ID_i,
    WB_i,
    MEM_i,
    data_o
);

input   [1:0]   signal_i;
input   [31:0]  ID_i, WB_i, MEM_i;

output  [31:0]  data_o;


assign data_o = (signal_i == 2'b00)? ID_i :
                (signal_i == 2'b01)? WB_i : MEM_i;

endmodule