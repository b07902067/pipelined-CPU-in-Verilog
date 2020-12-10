module CPU(
	clk_i,
    start_i,
    rst_i
);

input               clk_i;
input               rst_i;
input               start_i;


// define wire

wire [31:0] instruction;
wire [31:0] Instruction;
wire [31:0]	extend_res;
wire isZero;
wire isBranch;
wire pc_mux_select;
wire Ze;

wire [31:0] pc_in;
wire [31:0] pc_out;
wire [31:0] pc4_adder_out;
wire [31:0] branch_shift_immediates;
wire [31:0] branch_pc_out;

assign branch_shift_immediates = extend_res << 1;

wire isStall;
wire PCWrite;
wire noOp;

// ID var
wire control_2_idex_RegWrite;
wire control_2_idex_MemtoReg;
wire control_2_idex_MemRead;
wire control_2_idex_MemWrite;
wire [1:0] control_2_idex_ALUOp;
wire control_2_idex_ALUSrc;
wire [31:0] rd1;
wire [31:0] rd2;
wire [31:0] immediates;
wire [31:0] ID_PC;

// EX var
wire EX_RegWrite;
wire EX_MemtoReg;
wire EX_MemRead;
wire EX_MemWrite;
wire [1:0] EX_ALUOp;
wire EX_ALUSrc;
wire [31:0] EX_Rdata1;
wire [31:0] EX_Rdata2;
wire [4:0] EX_Rs1;
wire [4:0] EX_Rs2;
wire [4:0] EX_Rd;
wire [9:0] EX_ALUCtrl;
wire [3:0] ALUCtrl_out;
wire [31:0] ALU_out;
wire [31:0] EX_Src_MUX_out;




// MEM var
wire MEM_RegWrite;
wire MEM_MemtoReg;
wire MEM_MemRead;
wire MEM_MemWrite;
wire [4:0] MEM_rd;
wire [31:0] MEM_ALU_RES_AS_ADDRESS;
wire [31:0] MEM_WrData;
wire [31:0] DM_out;
wire [31:0] MEM_ALU_RES_AS_OUT;
wire [31:0] MEM_ALU_RES_2_MUXA;
wire [31:0] MEM_ALU_RES_2_MUXB;
assign MEM_ALU_RES_AS_OUT = MEM_ALU_RES_AS_ADDRESS;
assign MEM_ALU_RES_2_MUXA = MEM_ALU_RES_AS_ADDRESS;
assign MEM_ALU_RES_2_MUXB = MEM_ALU_RES_AS_ADDRESS;

// WB var
wire WB_RegWrite;
wire WB_MemtoReg;
wire [4:0] WB_rd_out;
wire [31:0] WB_MUX_rs1;
wire [31:0] WB_MUX_rs2;
wire [31:0] WB_result;

// others
wire [4:0] WB_rd_out_2_FORWARD;
wire [4:0] MEM_rd_2_FORWARD;
wire MEM_RegWrite_2_FORWARD;
wire WB_RegWrite_2_FORWARD;
assign WB_rd_out_2_FORWARD = WB_rd_out;
assign MEM_rd_2_FORWARD = MEM_rd;
assign MEM_RegWrite_2_FORWARD = MEM_RegWrite;
assign WB_RegWrite_2_FORWARD = WB_RegWrite;


wire [1:0] ForwardA;
wire [1:0] ForwardB;


wire [31:0] WB_result_2_MUXA;
wire [31:0] WB_result_2_MUXB;
assign WB_result_2_MUXA = WB_result;
assign WB_result_2_MUXB = WB_result;

wire [31:0] ALU_IN1;
wire [31:0] ALU_IN2;
wire [31:0] MUXB_out;
wire [31:0] EXMEM_reg2_in;

assign EXMEM_reg2_in = MUXB_out;


// data path



PC PC
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .start_i(start_i),
    .PCWrite_i(PCWrite),
    .pc_i(pc_in),
    .pc_o(pc_out)
);


Adder Add4_2PC(
    .data1_in   (pc_out),
    .data2_in   (4),
    .data_o     (pc4_adder_out)
);

Adder Add_PC_Branch(
    .data1_in   (ID_PC),
    .data2_in   (branch_shift_immediates),
    .data_o     (branch_pc_out)
);

MUX32 PC_MUX
(
	.data1_i    (pc4_adder_out),
    .data2_i    (branch_pc_out),
    .select_i   (pc_mux_select),
    .data_o     (pc_in)

);

REGEQ	RS1RS2
(
    .data1_i(rd1),
    .data2_i(rd2),
    .equal_o(isZero)
);

AND IsJunp
(
    .branch_i(isBranch),
    .equal_i(isZero),
    .branch_o(pc_mux_select)
);


HAZARD 	HAZRD_DETECT_UNIT
(
    .Rs1_i(Instruction[19:15]),
    .Rs2_i(Instruction[24:20]),
    .EXRd_i(EX_Rd),
    .ID_EXRead_i(EX_MemRead),
    .Stall_o(isStall),
    .PCWrite_o(PCWrite),
    .NoOp_o(noOp)
);




Instruction_Memory Instruction_Memory(
    .addr_i     (pc_out), 
    .instr_o    (instruction)
);

IFID IFID
(
    .clk_i(clk_i),
    .PC_i(pc_out),
    .Stall_i(isStall),
    .Flush_i(pc_mux_select),
    .Inst_i(instruction),
    .PC_o(ID_PC),
    .Inst_o(Instruction)
);

Control Control(
	.NoOp_i(noOp),
	.op_i(Instruction[6:0]),
	.RegWrite_o(control_2_idex_RegWrite),
    .MemtoReg_o(control_2_idex_MemtoReg),
    .MemRead_o(control_2_idex_MemRead),
    .MemWrite_o(control_2_idex_MemWrite),
    .ALUOp_o(control_2_idex_ALUOp),
    .ALUSrc_o(control_2_idex_ALUSrc),
    .Branch_o(isBranch)

);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (Instruction[19:15]),
    .RS2addr_i   (Instruction[24:20]),
    .RDaddr_i   (WB_rd_out), 
    .RDdata_i   (WB_result),
    .RegWrite_i (WB_RegWrite), 
    .RS1data_o   (rd1), 
    .RS2data_o   (rd2) 
);

IDEX IDEX(

	.clk_i(clk_i), 
    .RegWrite_i(control_2_idex_RegWrite),
    .MemtoReg_i(control_2_idex_MemtoReg),
    .MemRead_i(control_2_idex_MemRead),
    .MemWrite_i(control_2_idex_MemWrite),
    .ALUOp_i(control_2_idex_ALUOp),
    .ALUSrc_i(control_2_idex_ALUSrc),
    .Reg1_i(rd1),
    .Reg2_i(rd2),
    .Imm_i(extend_res),
    .funct_i({Instruction[31:25], Instruction[14:12]}),
    .Rs1_i(Instruction[19:15]),
    .Rs2_i(Instruction[24:20]),
    .Rd_i(Instruction[11:7]),
    .RegWrite_o(EX_RegWrite),
    .MemtoReg_o(EX_MemtoReg),
    .MemRead_o(EX_MemRead),
    .MemWrite_o(EX_MemWrite),
    .ALUOp_o(EX_ALUOp),
    .ALUSrc_o(EX_ALUSrc),
    .Reg1_o(EX_Rdata1),
    .Reg2_o(EX_Rdata2),
    .Imm_o(immediates),
    .funct_o(EX_ALUCtrl),
    .Rs1_o(EX_Rs1),
    .Rs2_o(EX_Rs2),
    .Rd_o(EX_Rd)

);

ALU_Control ALU_Control(
	.funct_i(EX_ALUCtrl),
    .ALUOp_i(EX_ALUOp),
    .ALUCtrl_o(ALUCtrl_out)

);

MUX32 MUX_ALUSrc(
    .data1_i    (MUXB_out),
    .data2_i    (immediates),
    .select_i   (EX_ALUSrc),
    .data_o     (ALU_IN2)
);


EXMEM EXMEM
(
    .clk_i(clk_i), 
    .RegWrite_i(EX_RegWrite),
    .MemtoReg_i(EX_MemtoReg),
    .MemRead_i(EX_MemRead),
    .MemWrite_i(EX_MemWrite),
    .Rd_i(EX_Rd),
    .ALUResult_i(ALU_out),
    .Reg2_i(EXMEM_reg2_in),
    .RegWrite_o(MEM_RegWrite),
    .MemtoReg_o(MEM_MemtoReg),
    .MemRead_o(MEM_MemRead),
    .MemWrite_o(MEM_MemWrite),
    .Rd_o(MEM_rd),
    .ALUResult_o(MEM_ALU_RES_AS_ADDRESS),
    .DATAWr_o(MEM_WrData)
);

Data_Memory Data_Memory
(
    .clk_i(clk_i), 
    .addr_i(MEM_ALU_RES_AS_ADDRESS), 
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_i(MEM_WrData),
    .data_o(DM_out)
);


MEMWB MEMWB
(
    .clk_i(clk_i),
    .RegWrite_i(MEM_RegWrite),
    .MemtoReg_i(MEM_MemtoReg),
    .ALUResult_i(MEM_ALU_RES_AS_OUT),
    .Rd_i(MEM_rd),
    .DATARd_i(DM_out),
    .RegWrite_o(WB_RegWrite),
    .MemtoReg_o(WB_MemtoReg),
    .ALUResult_o(WB_MUX_rs1),
    .Rd_o(WB_rd_out),
    .DATARd_o(WB_MUX_rs2)
);

MUX32 WB_MUX
(
	.data1_i    (WB_MUX_rs1),
    .data2_i    (WB_MUX_rs2),
    .select_i   (WB_MemtoReg),
    .data_o     (WB_result)

);

FORWARD FORWARD_UNIT
(
    .Rs1_i(EX_Rs1),
    .Rs2_i(EX_Rs2),
    .MEMRd_i(MEM_rd_2_FORWARD),
    .MEMRegWrite_i(MEM_RegWrite_2_FORWARD),
    .WBRd_i(WB_rd_out_2_FORWARD),
    .WBRegWrite_i(WB_RegWrite_2_FORWARD),
    .Forward1_o(ForwardA),
    .Forward2_o(ForwardB)
);


MUX32_4	MUX32_4A
(
    .signal_i(ForwardA),
    .ID_i(EX_Rdata1), 
    .WB_i(WB_result_2_MUXA),
    .MEM_i(MEM_ALU_RES_2_MUXA),
    .data_o(ALU_IN1)
);


MUX32_4	MUX32_4B
(
    .signal_i(ForwardB),
    .ID_i(EX_Rdata2), 
    .WB_i(WB_result_2_MUXB),
    .MEM_i(MEM_ALU_RES_2_MUXB),
    .data_o(MUXB_out)
);

Sign_Extend Sign_Extender
(
    .data_i(Instruction),
    .data_o(extend_res)
);

ALU ALU(
	.data1_i(ALU_IN1),
    .data2_i(ALU_IN2),
    .ALUCtrl_i(ALUCtrl_out),
    .data_o(ALU_out),
    .Zero_o(Ze)

);


endmodule