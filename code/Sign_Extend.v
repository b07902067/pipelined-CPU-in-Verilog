module Sign_Extend
(
    data_i,
    data_o
);

// Ports

input   [31:0]  data_i;
output  reg signed [31:0]  data_o;


wire    [19:0]  head;   
// Sign Extender


always@(data_i)begin

    if (data_i[6:0] == 7'b0100011) begin
        data_o = {{20{data_i[31]}}, {data_i[31:25], data_i[11:7]}};
    end
    else if (data_i[6:0] == 7'b1100011) begin
        data_o = {{20{data_i[31]}}, {data_i[31], {data_i[7], {data_i[30:25], data_i[11:8]}}}};
    end
    else begin
        data_o = {{20{data_i[31]}}, data_i[31:20]};
    end
end


endmodule



