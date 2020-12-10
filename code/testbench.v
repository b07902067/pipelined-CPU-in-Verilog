`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile, counter;
integer            stall, flush;
parameter          num_cycles = 64;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start),
    .rst_i  (Reset)
);
  
initial begin
    outfile = $fopen("output.txt") | 1;
    $dumpfile("CPU.vcd");
    $dumpvars;
    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 32'b0;
    end    
    CPU.Data_Memory.memory[0] = 5;
    // [D-MemoryInitialization] DO NOT REMOVE THIS FLAG !!!
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    // [RegisterInitialization] DO NOT REMOVE THIS FLAG !!!

    // TODO: initialize your pipeline registers
    //CPU.PC.pc_o = 32'b0;

    CPU.IFID.PC_o = 32'b0;
    CPU.IFID.Inst_o = 32'b0;
    //$fdisplay(outfile, "IFID_Inst_o = %b\n", CPU.IFID.Inst_o);
    //$fdisplay(outfile, "IFID_Inst_o = %b\n", CPU.instruction);
    
    CPU.IDEX.RegWrite_o = 1'b0;
    CPU.IDEX.MemtoReg_o = 1'b0;
    CPU.IDEX.MemRead_o = 1'b0;
    CPU.IDEX.MemWrite_o = 1'b0;
    CPU.IDEX.ALUSrc_o = 1'b0;
    CPU.IDEX.ALUOp_o = 2'b0;
    CPU.IDEX.Reg1_o = 32'b0;
    CPU.IDEX.Reg2_o = 32'b0;
    CPU.IDEX.Imm_o = 32'b0;
    CPU.IDEX.funct_o = 10'b0;
    CPU.IDEX.Rs1_o = 5'b0;
    CPU.IDEX.Rs2_o = 5'b0;
    CPU.IDEX.Rd_o = 5'b0;

    CPU.EXMEM.RegWrite_o = 1'b0;
    CPU.EXMEM.MemtoReg_o = 1'b0;
    CPU.EXMEM.MemRead_o = 1'b0;
    CPU.EXMEM.MemWrite_o = 1'b0;
    CPU.EXMEM.Rd_o = 5'b0;
    CPU.EXMEM.ALUResult_o = 32'b0;
    CPU.EXMEM.DATAWr_o = 32'b0;

    CPU.MEMWB.RegWrite_o = 1'b0;
    CPU.MEMWB.MemtoReg_o = 1'b0;
    CPU.MEMWB.ALUResult_o = 32'b0;
    CPU.MEMWB.DATARd_o = 32'b0;
    CPU.MEMWB.Rd_o = 5'b0;

    // Load instructions into instruction memory
    // Make sure you change back to "instruction.txt" before submission
    $readmemb("../testdata/instruction_4.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    // Make sure you change back to "output.txt" before submission
    outfile = $fopen("output.txt") | 1;
    
    Clk = 1;
    Reset = 1;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 0;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    if(counter == num_cycles)    // stop after num_cycles cycles
        $finish;

    // put in your own signal to count stall and flush
    if(CPU.HAZRD_DETECT_UNIT.Stall_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.IsJunp.branch_o == 1)flush = flush + 1;  

    // print PC
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "cycle = %d, Start = %0d, Stall = %0d, Flush = %0d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    //$fdisplay(outfile, "Instruction_IF = %b, Instruction_ID = %b\n", CPU.instruction, CPU.Instruction);
    //$fdisplay(outfile, "IFID_Inst_o = %b\n", CPU.IFID.Inst_o);
    //$fdisplay(outfile, "Control.RegWrite_o = %b, Control.MemtoReg_o = %b, Control.MemRead_o = %b, Control.MemWrite_o = %b, Control.ALUOp_o = %b, Control.ALUSrc_o = %b, Control.Branch_o = %b\n", 
    //CPU.Control.RegWrite_o, CPU.Control.MemtoReg_o, CPU.Control.MemRead_o, CPU.Control.MemWrite_o, CPU.Control.ALUOp_o, CPU.Control.ALUSrc_o, CPU.Control.Branch_o);
    //$fdisplay(outfile, "IDEX.RegWrite_o = %b, IDEX.MemtoReg_o = %b, IDEX.MemRead_o = %b, IDEX.MemWrite_o = %b, IDEX.ALUOp_o = %b, IDEX.ALUSrc_o = %b, IDEX.Reg1_o = %b, IDEX.Reg2_o = %b, IDEX.Imm_o = %b, IDEX.funct_o = %b, IDEX.Rs1_o = %b, IDEX.Rs2_o = %b, IDEX.Rd_o = %b\n", CPU.IDEX.RegWrite_o, CPU.IDEX.MemtoReg_o, CPU.IDEX.MemRead_o, CPU.IDEX.MemWrite_o, CPU.IDEX.ALUOp_o, CPU.IDEX.ALUSrc_o, CPU.IDEX.Reg1_o, CPU.IDEX.Reg2_o, CPU.IDEX.Imm_o, CPU.IDEX.funct_o, CPU.IDEX.Rs1_o, CPU.IDEX.Rs2_o, CPU.IDEX.Rd_o);
    //$fdisplay(outfile, "EXMEM.RegWrite_o = %b, EXMEM.MemtoReg_o = %b, EXMEM.MemRead_o = %b, EXMEM.MemWrite_o = %b, EXMEM.Rd_o = %b, EXMEM.ALUResult_o = %b, EXMEM.DATAWr_o = %b\n", CPU.EXMEM.RegWrite_o, CPU.EXMEM.MemtoReg_o, CPU.EXMEM.MemRead_o, CPU.EXMEM.MemWrite_o, CPU.EXMEM.Rd_o, CPU.EXMEM.ALUResult_o, CPU.EXMEM.DATAWr_o);
    //$fdisplay(outfile, "MEMWB.RegWrite_o = %b,MEMWB.MemtoReg_o = %b, MEMWB.ALUResult_o = %b, MEMWB.Rd_o = %b, MEMWB.DATARd_o = %b\n", CPU.MEMWB.RegWrite_o, CPU.MEMWB.MemtoReg_o, CPU.MEMWB.ALUResult_o, CPU.MEMWB.Rd_o, CPU.MEMWB.DATARd_o);
    //$fdisplay(outfile,"Rs1_i = %b, Rs2_i = %b, EXRd_i = %b, ID_EXRead_i = %b, NoOp = %b, PC_write = %b, Stall = %b\n", CPU.HAZRD_DETECT_UNIT.Rs1_i, CPU.HAZRD_DETECT_UNIT.Rs2_i, CPU.HAZRD_DETECT_UNIT.EXRd_i,  CPU.HAZRD_DETECT_UNIT.ID_EXRead_i, CPU.HAZRD_DETECT_UNIT.NoOp_o, CPU.HAZRD_DETECT_UNIT.PCWrite_o,  CPU.HAZRD_DETECT_UNIT.Stall_o);
    //$fdisplay(outfile,"ForwardA = %b, ForwardB = %b\n", CPU.ForwardA, CPU.ForwardB);
    //$fdisplay(outfile,"PC+4 = %b, PC+IMM = %b\n", CPU.Add4_2PC.data_o, CPU.Add_PC_Branch.data_o);
    //$fdisplay(outfile,"branch_i = %b, equal_i = %b, branch_o = %b\n", CPU.IsJunp.branch_i, CPU.IsJunp.equal_i, CPU.IsJunp.branch_o);
    //$fdisplay(outfile,"REGEQ.Rs1 = %b, REGEQ.Rs2 = %b, REGEQ.equal = %b\n", CPU.RS1RS2.data1_i, CPU.RS1RS2.data2_i, CPU.RS1RS2.equal_o);


    // print Registers
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %d, x8  = %d, x16 = %d, x24 = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "x1 = %d, x9  = %d, x17 = %d, x25 = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "x2 = %d, x10 = %d, x18 = %d, x26 = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "x3 = %d, x11 = %d, x19 = %d, x27 = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "x4 = %d, x12 = %d, x20 = %d, x28 = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "x5 = %d, x13 = %d, x21 = %d, x29 = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "x6 = %d, x14 = %d, x22 = %d, x30 = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "x7 = %d, x15 = %d, x23 = %d, x31 = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", CPU.Data_Memory.memory[0]);
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", CPU.Data_Memory.memory[1]);
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", CPU.Data_Memory.memory[2]);
    $fdisplay(outfile, "Data Memory: 0x0C = %10d", CPU.Data_Memory.memory[3]);
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", CPU.Data_Memory.memory[4]);
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", CPU.Data_Memory.memory[5]);
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", CPU.Data_Memory.memory[6]);
    $fdisplay(outfile, "Data Memory: 0x1C = %10d", CPU.Data_Memory.memory[7]);

    $fdisplay(outfile, "\n");
    
    counter = counter + 1;
    
      
end

  
endmodule
