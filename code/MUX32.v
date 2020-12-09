module MUX32
(
    data1_i,
    data2_i,
    select_i,
    data_o
);


// Ports
input   signed [31:0]  data1_i;
input   signed [31:0]  data2_i;
input   select_i;
output  reg signed [31:0]  data_o;

always@(data1_i, data2_i, select_i)begin

	data_o = (select_i == 1'b0)? data1_i:data2_i;

end



endmodule


