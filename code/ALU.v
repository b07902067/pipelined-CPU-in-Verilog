module ALU
(
	data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    Zero_o
);



// Ports
input	signed [31:0]	data1_i;
input	signed [31:0]	data2_i;
input	[3:0]	ALUCtrl_i;
output	reg signed [31:0]	data_o;
output	reg	Zero_o;
reg	[4:0]	shift_left_num;
reg	[4:0]	shift_right_num;


always@(data1_i, data2_i, ALUCtrl_i)begin
	case(ALUCtrl_i)
		4'b0000	:data_o = data1_i & data2_i;
		4'b0001	:data_o = data1_i ^ data2_i;
		4'b0010	:begin
					shift_left_num = data2_i[4:0];
					data_o = data1_i << shift_left_num;
				end
		4'b0011	:data_o = data1_i + data2_i;
		4'b0100	:data_o = data1_i - data2_i;
		4'b0101	:data_o = data1_i * data2_i;
		4'b0110	:data_o = data1_i + data2_i;
		4'b0111	:begin
					shift_right_num = data2_i[4:0];
					data_o = data1_i >>> shift_right_num;
				end
		4'b1000 :data_o = data1_i + data2_i;
		4'b1001 :data_o = data1_i - data2_i;

	endcase
	if(data_o == 32'b00000000000000000000000000000000)begin
		Zero_o = 1'b1;
	end
	else begin
		Zero_o = 1'b0;
	end


end


endmodule
