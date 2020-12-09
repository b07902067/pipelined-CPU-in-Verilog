# CA2020- Project1
###### tags: `computer architecture`






---
## Pipeline Unit

### IF/ID (Module name : `IFID`)

| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|PC	| `PC_i [31:0]`  |  `PC_o [31:0]`  | adder : PC + Imm
|Hazard Detection Unit	| `Stall_i` | 
|and gate in front of Control unit	| `Flush_i` |  
|Instruction Mem	| `Inst_i [31:0]`  | `Inst_o [31:0]` | Instruction Reg

```verilog=
module IFID
(
    clk_i,
    PC_i,
    Stall_i,
    Flush_i,
    Inst_i,
    PC_o,
    Inst_o
);
```

### ID/EX (Module name : `IDEX`)


| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
| Control Unit     |`RegWrite_i`    |`RegWrite_o` | EX/MEM | 
| Control Unit     |`MemtoReg_i`    |`MemtoReg_o`| EX/MEM |
| Control Unit     |`MemRead_i`     |`MemRead_o`| EX/MEM <br>Hazard Detection Unit|
| Control Unit     |`MemWrite_i`    |`MemWrite_o`| EX/MEM |
| Control Unit     |`ALUOp_i [1:0]` | `ALUOp_o [1:0]` | ALU control unit
| Control Unit     |`ALUSrc_i` | `ALUSrc_o` | MUX_ALUSrc
| Refister file    |`Reg1_i [31:0]` | `Reg1_o [31:0]` | MUX_reg1 
| Refister file    |`Reg2_i [31:0]` |  `Reg2_o [31:0]` | MUX_reg2<br>EX/MEM
| Imm Gen          |`Imm_i [31:0]` | `Imm_o [31:0]` | MUX_ALUSrc
| Instruction Reg  |`instruction [31-25, 14-12]`(`funct_i[9:0]`) | `funct_o[9:0]`  | ALU Control Unit
| Instruction Reg  |`Instrunction [19-15]` (`Rs1_i [4:0]`) | `Rs1_o [4:0]` | forward unit 
| Instruction Reg  |`Instrunction [24-20]` (`Rs2_i [4:0]`) | `Rs2_o [4:0]` | forward unit 
| Instruction Reg  |`Instrunction [11-7]` (`Rd_i [4:0]`) |`Rd_o [4:0]`  | EX/MEM<br>Hazard Detection Unit | 

```verilog=
module IDEX
(
    clk_i, 
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    Reg1_i,
    Reg2_i,
    Imm_i,
    funct_i,
    Rs1_i,
    Rs2_i,
    Rd_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Reg1_o,
    Reg2_o,
    Imm_o,
    funct_o,
    Rs1_o,
    Rs2_o,
    Rd_o
);
```

    

### EX/MEM (Module name : `EXMEM`)
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|ID/EX  | `RegWrite_i` | `RegWrite_o` | MEM/WB<br>Forwarding unit | 
|ID/EX	| `MemtoReg_i` |  `MemtoReg_o` | MEM/WB | 
|ID/EX	| `MemRead_i` |  `MemRead_o` | Data Mem | 
|ID/EX	| `MemWrite_i` |  `MemWrite_o` |  Data Mem | 
|ID/EX	|  `Rd_i [4:0]` |  `Rd_o [4:0]` | MEM/WB<br>Forwarding Unit |
|ALU	| `ALUresult_i [31:0]` | `ALUResult_o [31:0]` |  Data Mem (Address)<br>MEM/WB<br>MUX_Reg1<br>MUX_Reg2| 
|Register file	| `Reg2_i [31:0]`  | `DATAWr_o [31:0]` |  Data Mem (Write data)| 

```verilog=
module EXMEM
(
    clk_i, 
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    Rd_i,
    ALUResult_i,
    Reg2_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Rd_o,
    ALUResult_o,
    DATAWr_o,
);
```

### MEM/WB (Module name : `MEMWB`)
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|EX/MEM   | `RegWrite_i` |  `RegWrite_o` | Register file
|EX/MEM	| `MemtoReg_i` | `MemtoReg_o` | MUX_Mem_to_Reg
|EX/MEM	| `ALUResult_i [31:0]` |  `ALUResult_o [31:0]` | MUX_Mem_to_Reg
|EX/MEM	| `Rd_i [4:0]`  |  `Rd_o [4:0]`  | Register file<br>Forwarding Unit
|Data Mem	| `DATARd_i [31:0]` | `DATARd_o [31:0]` | MUX_Mem_to_Reg

```verilog=
module MEMWB
(
    clk_i,
    RegWrite_i,
    MemtoReg_i,
    ALUResult_i,
    Rd_i,
    DATARd_i,
    RegWrite_o,
    MemtoReg_o,
    ALUResult_o,
    Rd_o,
    DATARd_o,
);
```

---

## New module

### MUX32_4 (Module name : `MUX32_4`)
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
| Forwarding Unit   |  `signal_i`  |
|  ID/EX  |  `ID_i`  |
|  MUX_Mem_to_Reg  |  `WB_i`  |
|  EX/MEM (ALUResult)  |  `MEM_i`  |
|    |   |  `data_o`  | ALU

```verilog=
module MUX32_4
(
    signal_i,
    ID_i, 
    WB_i,
    MEM_i,
    data_o
);

assign data_o = (signal_i == 2'b00)? ID_i :
                (signal_i == 2'b01)? WB_i : MEM_i;
```

### Forwarding Unit
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|ID/EX  | `Rs1_i [4:0]`   |    |    |
|ID/EX  | `Rs2_i [4:0]`   |    |    |
|EX/MEM | `MEMRd_i [4:0]` |    |    |
|EX/MEM | `MEMRegWrite_i` |    |    |
|MEM/WB | `WBRd_i [4:0]`  |    |    |
|MEM/WB | `WBRegWrite_i`   |    |    |
|       |                 | `Forward1_o`  | MUX32_4_A   |
|       |                 | `Forward2_o`  | MUX32_4_B   |

```verilog=
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
```

### Hazard Detection Unit
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|  Instruction Reg  |  `Rs1_i [4:0]`(Instrunction [19-15])  |    |
|  Instruction Reg  |  `Rs2_i [4:0]`(Instrunction [24-20])  |    |
|  ID/EX  |  `EXRd_i [4:0]`  |    |
|  ID/EX  |  `EX_MEMRead_i` |    |
|    |    | `Stall_o`   | ID/EX
|    |    | `PCWrite_o` | MUX32_PC
|    |    | `NoOp_o` | Control Unit

