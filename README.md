# CA2020- Project1
###### tags: `computer architecture`

## Development environment ---  MacOS

---
## Implementation
### Control and ALU_Control
- **Control** 
    - **Input**
        - 讀入 Opcode ，判斷當前指令的 signal 應該為何並輸出
        - 新增 `branch_o` 、 `MEMRead_o`、 `MEMWrite_o` 、 `MEM_to_Reg_o`的 output 
        - 為了處理 Stall 的情況，會讀入來自 `Hazard Detection Unit` 的 `NoOp` input ，當 `NoOp` = 1 時，所有輸出的 signal  = 0 ，表示下一個進入 EX Stage 的指令將不會進行任何寫入動作。
    - **output** (`NoOp` 為 0 的情況)
        - 在 `ALUOp` 輸出的部分，為了區分 `lw` 、 `sw` 以及 `R-Type` 和 `I-Type`， 所以將做不同的輸出。
            - 因為 `lw` 和 `sw` 情況下， `funct3` 都是 `010` ，且 ALU 的動作都是 `ADD` ，因此可以共用一種 `ALUOp` ，在這邊設計為 `ALUOp = 00`
            - `I-Type` : `ALUOp = 11`
            - `R-Type` : `ALUOp = 10`
            - `beq` : `ALUOp = 01`

        - `branch_o` 不會傳給 `IDEX` ，會傳給 `AND Gate` 判斷 `beq` 是否成立。並且有關寫入動作的 Signal (`RegWrite`, `MemWrite`)都必須為 `0` 。以防 `beq` 不成立時，有其他的寫入動作。
        - 其他 output 的設計
            - `MemtoReg` 的部分，`sw` 和 `beq` 因為 `RegWrite` 已經等於 0 ，確保不會做寫入，因此 `MemtoReg` 的值可忽略。只是為了方便設計成 0 
            <br>

            | Instruction | `RegWrite` | `MemtoReg`| `MemRead`| `MemWrite`| `ALUOp`| `ALUSrc`| `Branch`
            | :--------: | :--------: | :--------: | :--------: | :--------: | :--------: | :--------: | :--------: |
            | `lw`     |   1   |   1   |  1  |  0  |  00 | 1 | 0
            | `sw`     |   0   |   0   |  0  |  1  |  00 | 1 | 0
            | `R-Type` |   1   |   0   |  0  |  0  |  10 | 0 | 0
            | `I_Type` |   1   |   0   |  0  |  0  |  11 | 1 | 0
            | `beq`    |   0   |   0   |  0  |  0  |  01 | 1 | 1
 
         
- **ALU_Control**
    - 讀入 `ALUOp` 以及 Function Field，並依此對所有instruction map 出一一對應的 alu control output。 
    -

| Instruction | code | 
| -------- | -------- | 
|  and   |   0000 | 
|  xor   |    0001    |
|    sll    |    0010    |
|    add    |    0011    |
|    sub    |    0100    |
|    mul    |    0101    |
|    sw, lw    |    1000    |
|    beq    |    1001    |

    


### Pipeline Register

- **IF/ID**
    - input 和 output 如下方表格
    - output 必需設定為 register ，在 clock posedge 的時候使用 nonblocking (`<=`) 的方式盡快將特定的值送給 output。
    - 先考慮 Flush ，再考慮 Stall 
    - 當 `Flush_i` = 1 時，表示 `beq` 的條件成立，不會執行目前在 IF stage 讀入的指令，因此會把 `Inst_o` 這個代表指令的 output 賦值為 32 bits 的 0。
        - 因為全部都是 0 的指令不會更改任何 register 或是 memory 的值，所以不會產生其他影響。
    - 當 `Flush_i` = 0，且 `Stall_i` = 1 時，表示必須讓當前在 ID stage 的指令下一個 cycle 時也停留在 ID stage ，因此不更新 `Inst_o` 的值，這樣該指令在下一個 cycle 時，也會存在於 ID stage。
        - **++這裡遇到的問題將寫在後面的 Difficulties encountered and solutions 部分。++**
    - 當 `Flush_i` = 0，且 `Stall_i` = 0 時，表示正常的執行指令，可以將 ID stage 的指令送進 IF stage 。此時就將 `Inst_o` 的值設定為 `Inst_i` ，`PC_o` 的值設定為 `PC_i`。
    <br>

    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    |PC	| `PC_i [31:0]`  |  `PC_o [31:0]`  | adder : PC + Imm
    |Hazard Detection Unit	| `Stall_i` | 
    |AND gate in front of Control unit	| `Flush_i` |  
    |Instruction Mem	| `Inst_i [31:0]`  | `Inst_o [31:0]` | Instruction Reg





- **ID/EX**
    - input 和 output 如下方表格
    - output 必需設定為 register ，在 clock posedge 的時候使用 nonblocking (`<=`) 的方式盡快將對應的的 input 送給 output。


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
    | Instruction Reg  |`Instruction Reg [31-25, 14-12]`(`funct_i[9:0]`) | `funct_o[9:0]`  | ALU Control Unit
    | Instruction Reg  |`Instrunction Reg [19-15]` (`Rs1_i [4:0]`) | `Rs1_o [4:0]` | forward unit 
    | Instruction Reg  |`Instrunction Reg [24-20]` (`Rs2_i [4:0]`) | `Rs2_o [4:0]` | forward unit 
    | Instruction Reg  |`Instrunction Reg [11-7]` (`Rd_i [4:0]`) |`Rd_o [4:0]`  | EX/MEM<br>Hazard Detection Unit | 


    

-  **EX/MEM** 
    - input 和 output 如下方表格
    - output 必需設定為 register ，在 clock posedge 的時候使用 nonblocking (`<=`) 的方式盡快將對應的的 input 送給 output。

    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    |ID/EX  | `RegWrite_i` | `RegWrite_o` | MEM/WB<br>Forwarding unit | 
    |ID/EX	| `MemtoReg_i` |  `MemtoReg_o` | MEM/WB | 
    |ID/EX	| `MemRead_i` |  `MemRead_o` | Data Mem | 
    |ID/EX	| `MemWrite_i` |  `MemWrite_o` |  Data Mem | 
    |ID/EX	|  `Rd_i [4:0]` |  `Rd_o [4:0]` | MEM/WB<br>Forwarding Unit |
    |ALU	| `ALUresult_i [31:0]` | `ALUResult_o [31:0]` |  Data Mem (Address)<br>MEM/WB<br>MUX_Reg1<br>MUX_Reg2| 
    |Register file	| `Reg2_i [31:0]`  | `DATAWr_o [31:0]` |  Data Mem (Write data)| 



- **MEM/WB** 
    - input 和 output 如下方表格
    - output 必需設定為 register ，在 clock posedge 的時候使用 nonblocking (`<=`) 的方式盡快將對應的的 input 送給 output。
    
| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|EX/MEM   | `RegWrite_i` |  `RegWrite_o` | Register file
|EX/MEM	| `MemtoReg_i` | `MemtoReg_o` | MUX_Mem_to_Reg
|EX/MEM	| `ALUResult_i [31:0]` |  `ALUResult_o [31:0]` | MUX_Mem_to_Reg
|EX/MEM	| `Rd_i [4:0]`  |  `Rd_o [4:0]`  | Register file<br>Forwarding Unit
|Data Mem	| `DATARd_i [31:0]` | `DATARd_o [31:0]` | MUX_Mem_to_Reg


### Forwarding Unit
-  input, output 如下表， output 將會送給 ALU 之前的 MUX 。
- 判斷 IDEX 的 `Rs1` 以及 `Rs2`，是否和 EXMEM 或 MEMWB 的 `Rd` 一樣。
- 在 MEMWB 的 Rd 和 RegWrite 都不為 0 的前提下，
    - 若 `MEMWBRd_i` 和 IDEX 的 `Rs1` 相等，代表 ALU 必須使用 WB Stage 裡 Mem_to_Reg 的 MUX32 所輸出的值代替原本 `Rs1` 內的值，因此 `ForwardA` = `01` ; 
    - 若 `MEMWBRd_i` 和 IDEX 的 Rs2 相等，`ForwardB` = `01` 
- 在 EXMEM 的 Rd 和 RegWrite 都不為 0 的前提下，
    - 若 `EXMEMRd_i` 和 IDEX 的 `Rs1` 相等，代表 ALU 必須使用 MEM Stage 裡 ALU result 的值代替原本 `Rs1` 內的值，因此 `ForwardA` = `10` ; 
    - 若 `EXMEMRd_i` 和 IDEX 的 Rs2 相等，`ForwardB` = `10`
- 其他情況下，ALU 會使用來自 IDEX 的值，因此輸出 `00`。

| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|ID/EX  | `Rs1_i [4:0]`   |    |    |
|ID/EX  | `Rs2_i [4:0]`   |    |    |
|EX/MEM | `EXMEMRd_i [4:0]` |    |    |
|EX/MEM | `EXMEMRegWrite_i` |    |    |
|MEM/WB | `MEMWBRd_i [4:0]`  |    |    |
|MEM/WB | `MEMWBRegWrite_i`   |    |    |
|       |                 | `Forward1_o [1:0]`   | MUX32_4_A   |
|       |                 | `Forward2_o [1:0]`  | MUX32_4_B   |


### Hazard Detection Unit
-  input, output 如下表， output 將會送給 IFID 以及 PC 以及 Control Unit 。
- 判斷目前位於 ID Stage 中的指令，其 `Rs1` 或 `Rs2` 是否和位於 EX stage 的指令的 `Rd` 相等。以及檢查 IDEX 輸出的 MemRead signal ，假如是 1 的話就代表目前在 EX Stage 的指令是 load。滿足上述兩個條件的話，當前在 ID Stage 的指令必須 Stall 一個 cycle 。
- 上述是為了避免 ID Stage 的指令進入 EX Stage 後，沒辦法透過 Forward 獲得最新的值。
- 當發生 Stall 的時候， 
    - `Stall_o = 1` 將送給 IFID Register ，告訴他不要將目前 output 的指令更新成 IF Stage 的指令，以便在下一個 Cycle 也能使用現在在 ID Stage 內的指令。
    - `PCWrite_o = 0` 將送給 PC ，使其不要更新，也是為了確保下一個 Cycle 在 IF Stage 裡的值會和這一個 Cycle 相同。
    - `NoOp_o = 1` 將送給 Control Unit ，使 Control Unit 將所有輸出的訊號設定為 0。這樣在下一個 Cycle 時，送進 EX Stage 的指令才不會執行任何寫入動作。
- 若沒有 Stall ，則 
    - `Stall_o = 0`， IFID 會正常更新 ID Stage 內的指令 
    - `PCWrite_o = 1` ， PC 會被更新
    - `NoOp_o = 0` ，所有 Signal 正常輸出 

| from | input | output | to| 
| :--------: | :-------- | --------: | :--------: |
|  Instruction Reg  |  `Rs1_i [4:0]`(Instrunction [19-15])  |    |
|  Instruction Reg  |  `Rs2_i [4:0]`(Instrunction [24-20])  |    |
|  ID/EX  |  `EXRd_i [4:0]`  |    |
|  ID/EX  |  `ID_EXRead_i` |    |
|    |    | `Stall_o`   | ID/EX
|    |    | `PCWrite_o` | PC
|    |    | `NoOp_o` | Control Unit


### testbench
- 將所有 pipeline register  初始化成 0 ，如此一來在第一個指令成功被執行完之前，才不會有不該有的寫入動作，也不會產生 `X` 影響 Control Unit 、 Hazard Detection Unit 和 Forward Unit 的判斷。
    - **++這裡遇到的問題將寫在後面的 Difficulties encountered and solutions 部分。++**

### Others

-  **MUX32_4** 
    -  input 及 output 如下表，會接收來自 Forwarding Unit 的 signal 。以及來自 IDEX 的 register 的值、EXMEM 的 ALU result 和 WB Stage 的 MEM_to_REG MUX 的輸出。
    - 放在 ALU 之前，選擇要使用來自當前 ID Stage 的 register output ，或是從 MEM Stage 或 WB Stage 的 RD forward 過來的值。
    - 當 `signal_i` = 00 時，會輸出來自 IDEX 的 register 的值
    - 當 `signal_i` == 01 時，會輸出 WB Stage 的 MEM_to_REG MUX 的輸出的值
    - 當 `signal_i` == 00 時，會輸出 EXMEM 的 ALU result
    
    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    | Forwarding Unit   |  `signal_i`  |
    |  ID/EX  |  `ID_i`  |
    |  MUX_Mem_to_Reg  |  `WB_i`  |
    |  EX/MEM (ALUResult)  |  `MEM_i`  |
    |    |   |  `data_o`  | ALU


- **REGEQ**
    - 讀取 Register File 輸出的 Rs1 和 Rs2 內的數值，比較是否相等，並輸出給 AND gate ，幫助判斷 `beq`。
    - 若相等，輸出 `1` ，若不同，輸出 `0`。 

    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    | Register File   |  `data1_i`  |
    |  Register File  |  `data2_i`  |
    |    |   |  `equal_o`  | AND

- **AND**
    - 判斷 `beq` ，從 Control Unit 讀取 `branch_o` 以及從 REGEQ 讀取 `equal_o`
    - 若兩者都是 `1` 的話，表示當前在 ID Stage 的指令是 `beq` 且 Rs1 及 Rs2 的內容相等，輸出 `1` ，反之輸出 `0`。
    
    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    | Control Unit   |  `branch_i`  |
    |  REGEQ  |  `equal_i`  |
    |    |   |  `beq_o`  | ALU

- **Sign_Extend**
    - input 從原本的最後 12 bits 變成整個 instruction (32 bits) 
    - 因為新增的 `sw` 及 `beq` 指令， immediate 的欄位將不再只是最後 12 bits ，因此傳入整個 instruction ，並在 `Sign_Extend` 內部判斷 imm 的值。
    - 根據 instruction 的前 7 個 bits (Opcodes) 判斷，
        - 若為 `01000111` ，即 `sw` 指令 ， `imm = instruction[31:25] + instruction [11:7]` 
        - 若為 `1100011` ，即 `beq` 指令 ，imm = `instruction[31] + instruction [7] + instruction[30:25] + instruction [11:8]`
        - 其他情況下，imm = 最後 12 bits
    - 因為三者的 MSB 都是 `instruction[31]` ，即 instruction 的 MSB ，因此將 `instruction[31]`  複製 20 次之後，再和 imm concate 起來作為輸出。
     
    | from | input | output | to| 
    | :--------: | :-------- | --------: | :--------: |
    | Instruction Register   |  `data_i`  |
    |    |   |  `data_o`  | IDEX<br>PC ADDER


### CPU
根據 Data Path 接線，用 wire 串接 functional blocks。


---

### Difficulties encountered and solutions
### *Difficulty 1.*  
##### 開始跑的時候 IFID 輸出的指令全部都是 `x`
在 `testbench` 的 `initial block` 中，有先行將 `IFID` 的 `instruction output` 初始化成 `32'b0` 。但此時 `IFID` 左方 `instruction input` 的線並沒有被初始化，其上的值是全為 `x`。一旦開始跑指令的時候，第一個 `clock posedge` 時，因為還沒有 Flush 和 Stall ， `IFID`會把 `instruction output` 更新成 `instruction input`，即 `32'bx` 。
在 ID Stage 如果出現全為 `x` 的指令的話，Control Unit 就無從判斷該如何輸出 signal，因而輸出 `x` 。
這導致之後的幾個 cycle 內，`IDEX` 、`EXMEM`和 `MEMWB`的 signal output 輸出大量的 `x` ，讓 `Hazard Detection Unit`  也輸出 `x` ，因此執行錯誤。
#### *Solution 1.*
在 IFID 時，倘若沒有發生 Flush 和 Stall 的情況下，額外判斷 input 的 `instruction` 是否為 `x` 。若是 `x` 的話，則 `output instruction` 設定為 `32'b0`

### *Difficulty 2.*
之後發現 *Solution 1* 不足以解決問題，因為除了 `IFID` 外，其他 pipeline register 也會在一開始的 posedge 將 output 更新成 input 。 此時發現`IDEX` 輸出的 Signal 全為 `x` 。原因是因為沒有將 `Control Unit` 的輸出初始化成全為 `0` 。
(`Control Unit`  除了 `branch` 以外的 signal output 會作為 `IDEX` 的 input)
#### *Solution 2.*
在 Control Unit 內部，將 output 設定成 Register ，並且全部初始化成 `0` 。

### *Note*
上述兩個 solution 只針對 Signal 以及 `IFID` 的部分處理，是因為在 `testbench.v` 中有先把所有 pipeline register 的 output register 初始化成 `0` 。第一個 clock posedge 時， `IDEX` 、 `EXMEM` 以及 `MEMWB` 的 `Rd` (Destination Register) 欄位還是會更新成 `0` ，因此不會影響 `Forwarding Unit` 的判斷。
而 `IFID` 因為位於最左方，也無法將 Instruction Memory 的輸出初始化 ( 因為是 wire ) ，所以一開始才會被更新成 `x`。








