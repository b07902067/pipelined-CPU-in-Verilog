module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

// Ports
input   [9:0]   funct_i;
input   [1:0]   ALUOp_i;
output  reg[3:0]   ALUCtrl_o;

//assign

always@(funct_i, ALUOp_i)begin



	if(ALUOp_i == 2'b11)begin	//I type
		case(funct_i[0])
			1'b0	:ALUCtrl_o = 4'b0110;	//addi
			1'b1	:ALUCtrl_o = 4'b0111;	//srai
			default	:;
		endcase
	end

	else if (ALUOp_i == 2'b10) begin	//R type
		case(funct_i)
			10'b0000000111	:ALUCtrl_o = 4'b0000;	//and
			10'b0000000100	:ALUCtrl_o = 4'b0001;	//xor
			10'b0000000001	:ALUCtrl_o = 4'b0010;	//sll
			10'b0000000000	:ALUCtrl_o = 4'b0011;	//add
			10'b0100000000	:ALUCtrl_o = 4'b0100;	//sub
			10'b0000001000	:ALUCtrl_o = 4'b0101;	//mul
			default	:;
		endcase

	end

	else if (ALUOp_i == 2'b00)begin
		ALUCtrl_o = 4'b1000;	// sw, lw
	end

	else begin
		ALUCtrl_o = 4'b1001;	//beq

	end


end



endmodule