module Control(
	NoOp_i,
	op_i,
	RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Branch_o

);


// Ports

input		NoOp_i;
input [6:0] op_i;
output reg RegWrite_o;
output reg MemtoReg_o;
output reg MemRead_o;
output reg MemWrite_o;
output reg [1:0] ALUOp_o;
output reg ALUSrc_o;
output reg Branch_o;


// assign

always@(op_i, NoOp_i)begin

	if (NoOp_i == 1'b0) begin
		MemtoReg_o = 1'b0;
		RegWrite_o = 1'b0;
		ALUSrc_o = 1'b0;
		ALUOp_o = 2'b00;
		MemWrite_o = 1'b0;
		Branch_o = 1'b0;
		MemRead_o = 1'b0;
	end
	else begin
		case(op_i)
			7'b0110011	:begin	// R-type
							MemtoReg_o = 1'b0;
							RegWrite_o = 1'b1;
							ALUSrc_o = 1'b0;
							ALUOp_o = 2'b10;
							MemWrite_o = 1'b0;
							Branch_o = 1'b0;
							MemRead_o = 1'b0;
						end
			7'b0010011	:begin		// I type
							MemtoReg_o = 1'b0;
							RegWrite_o = 1'b1;
							ALUSrc_o = 1'b1;
							ALUOp_o = 2'b11;
							MemWrite_o = 1'b0;
							Branch_o = 1'b0;
							MemRead_o = 1'b0;
						end
			7'b0000011	:begin			//lw
							MemtoReg_o = 1'b1;
							RegWrite_o = 1'b1;
							ALUSrc_o = 1'b1;
							ALUOp_o = 2'b00;
							MemWrite_o = 1'b0;
							Branch_o = 1'b0;
							MemRead_o = 1'b1;
						end
			7'b0100011	:begin			//sw
							MemtoReg_o = 1'b0;
							RegWrite_o = 1'b0;
							ALUSrc_o = 1'b1;
							ALUOp_o = 2'b00;
							MemWrite_o = 1'b1;
							Branch_o = 1'b0;
							MemRead_o = 1'b0;
						end
			7'b0000011	:begin			//beq
							MemtoReg_o = 1'b0;
							RegWrite_o = 1'b0;
							ALUSrc_o = 1'b1;
							ALUOp_o = 2'b01;
							MemWrite_o = 1'b0;
							Branch_o = 1'b1;
							MemRead_o = 1'b0;
						end
			default	:;
		endcase
	end
end

endmodule



