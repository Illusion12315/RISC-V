`include "defines.v"
// ********************************************************************************** //
//---------------------------------------------------------------------
// RV32I_core
//---------------------------------------------------------------------
module RV32I_core_by_cxz (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         rd_en_i                    ,
    input  wire        [  31:0]         rd_addr_i                  ,
    output wire        [  31:0]         rd_data_o                   
);
wire                   [  31:0]         instruction_addr_if2dff    ;
wire                   [  31:0]         instruction_addr_dff2id    ;
wire                   [  31:0]         instruction_addr_id2dff    ;
wire                   [  31:0]         instruction_addr_dff2ex    ;
wire                   [  31:0]         instruction_addr_ex2dff    ;
wire                   [  31:0]         instruction_addr_dff2mem   ;
wire                   [  31:0]         instruction_addr_mem2if    ;
wire                   [  31:0]         jump_addr_id2if            ;
wire                   [  31:0]         instruction_if2dff         ;
wire                   [  31:0]         instruction_dff2id         ;
wire                   [  31:0]         rd_wdata_wb2id             ;
wire                   [  31:0]         rs1_rdata_id2dff           ;
wire                   [  31:0]         rs2_rdata_id2dff           ;
wire                   [  31:0]         imm_gen_id2dff             ;
wire                   [  31:0]         rs1_rdata_dff2ex           ;
wire                   [  31:0]         rs2_rdata_dff2ex           ;
wire                   [  31:0]         imm_gen_dff2ex             ;
wire                   [  31:0]         alu_result_mem2dff         ;
wire                   [  31:0]         rs2_rdata_ex2dff           ;
wire                   [  31:0]         alu_result_ex2dff          ;
wire                   [  31:0]         rs2_rdata_dff2mem          ;
wire                   [  31:0]         alu_result_dff2mem         ;
wire                   [  31:0]         DM_rd_data_mem2dff         ;
wire                   [  31:0]         DM_rd_data_dff2wb          ;
wire                   [  31:0]         alu_result_dff2wb          ;

wire                   [   4:0]         rd_waddr_wb2id             ;
wire                   [   4:0]         rd_id2dff                  ;
wire                   [   4:0]         rs1_id2dff                 ;
wire                   [   4:0]         rs2_id2dff                 ;
wire                   [   4:0]         rd_dff2ex                  ;
wire                   [   4:0]         rs1_dff2fu                 ;
wire                   [   4:0]         rs2_dff2fu                 ;
wire                   [   4:0]         rd_ex2dff                  ;
wire                   [   4:0]         rd_dff2wb                  ;
wire                   [   4:0]         rd_mem2dff                 ;
wire                   [   4:0]         rd_dff2mem                 ;

wire                   [   3:0]         ALU_ctrl_id2dff            ;
wire                   [   3:0]         ALU_ctrl_dff2ex            ;

wire                   [   1:0]         ForwardA_fu2ex             ;
wire                   [   1:0]         ForwardB_fu2ex             ;
wire                   [   1:0]         ALUOp_id2dff               ;
wire                   [   1:0]         ALUOp_dff2ex               ;

wire                                    condition_en_ex2dff        ;
wire                                    condition_en_dff2mem       ;
wire                                    PCSrc_mem2if               ;
wire                                    stall_en                   ;
wire                                    jump_en_id2if              ;
wire                                    rd_wr_en_wb2id             ;
wire                                    ALUSrc_id2dff              ;
wire                                    Branch_id2dff              ;
wire                                    MemRead_id2dff             ;
wire                                    MemWrite_id2dff            ;
wire                                    RegWrite_id2dff            ;
wire                                    MemtoReg_id2dff            ;
wire                                    RegWrite_dff2wb            ;
wire                                    MemtoReg_dff2wb            ;
wire                                    RegWrite_dff2mem           ;
wire                                    MemtoReg_dff2mem           ;
wire                                    Branch_dff2mem             ;
wire                                    MemRead_dff2mem            ;
wire                                    MemWrite_dff2mem           ;
wire                                    RegWrite_ex2dff            ;
wire                                    MemtoReg_ex2dff            ;
wire                                    Branch_ex2dff              ;
wire                                    MemRead_ex2dff             ;
wire                                    MemWrite_ex2dff            ;
wire                                    ALUSrc_dff2ex              ;
wire                                    Branch_dff2ex              ;
wire                                    MemRead_dff2ex             ;
wire                                    MemWrite_dff2ex            ;
wire                                    RegWrite_dff2ex            ;
wire                                    MemtoReg_dff2ex            ;
wire                                    RegWrite_mem2dff           ;
wire                                    MemtoReg_mem2dff           ;
//---------------------------------------------------------------------
// IF
//---------------------------------------------------------------------
instruction_fetch  instruction_fetch_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .PCSrc_i                           (PCSrc_mem2if              ),
    .instruction_addr_i                (instruction_addr_mem2if   ),
    // from hazard_detection_unit
    .stall_en_i                        (stall_en                  ),
    .jump_addr_i                       (jump_addr_id2if           ),
    .jump_en_i                         (jump_en_id2if             ),
    //----------------------------output----------------------------
    .instruction_addr_o                (instruction_addr_if2dff   ),
    .instruction_o                     (instruction_if2dff        ) 
  );
//---------------------------------------------------------------------
// IF_ID
//---------------------------------------------------------------------
instruction_fetch2instruction_decode  instruction_fetch2instruction_decode_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .instruction_addr_i                (instruction_addr_if2dff   ),
    .instruction_i                     (instruction_if2dff        ),
    //----------------------------output----------------------------
    .instruction_addr_o                (instruction_addr_dff2id   ),
    .instruction_o                     (instruction_dff2id        ) 
  );
//---------------------------------------------------------------------
// ID
//---------------------------------------------------------------------
instruction_decode  instruction_decode_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .rd_wr_en_i                        (rd_wr_en_wb2id            ),
    .rd_waddr_i                        (rd_waddr_wb2id            ),
    .rd_wdata_i                        (rd_wdata_wb2id            ),
    .instruction_addr_i                (instruction_addr_dff2id   ),
    .instruction_i                     (instruction_dff2id        ),
    .stall_en_i                        (stall_en                  ),
    .PCSrc_i                           (PCSrc_mem2if              ),
    //----------------------------output----------------------------
    .instruction_addr_o                (instruction_addr_id2dff   ),
    .rs1_rdata_o                       (rs1_rdata_id2dff          ),
    .rs2_rdata_o                       (rs2_rdata_id2dff          ),
    .imm_gen_o                         (imm_gen_id2dff            ),
    .rd_o                              (rd_id2dff                 ),
    .ALU_ctrl_o                        (ALU_ctrl_id2dff           ),
    .rs1_o                             (rs1_id2dff                ),
    .rs2_o                             (rs2_id2dff                ),
    .ALUSrc_o                          (ALUSrc_id2dff             ),
    .ALUOp_o                           (ALUOp_id2dff              ),
    .Branch_o                          (Branch_id2dff             ),
    .MemRead_o                         (MemRead_id2dff            ),
    .MemWrite_o                        (MemWrite_id2dff           ),
    .RegWrite_o                        (RegWrite_id2dff           ),
    .MemtoReg_o                        (MemtoReg_id2dff           ),
    .jump_addr_o                       (jump_addr_id2if           ),
    .jump_en_o                         (jump_en_id2if             ) 
  );
//---------------------------------------------------------------------
// ID_EX
//---------------------------------------------------------------------
instruction_decode2execute  instruction_decode2execute_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .instruction_addr_i                (instruction_addr_id2dff   ),
    .rs1_rdata_i                       (rs1_rdata_id2dff          ),
    .rs2_rdata_i                       (rs2_rdata_id2dff          ),
    .imm_gen_i                         (imm_gen_id2dff            ),
    .rd_i                              (rd_id2dff                 ),
    .ALU_ctrl_i                        (ALU_ctrl_id2dff           ),
    .rs1_i                             (rs1_id2dff                ),
    .rs2_i                             (rs2_id2dff                ),
    .ALUSrc_i                          (ALUSrc_id2dff             ),
    .ALUOp_i                           (ALUOp_id2dff              ),
    .Branch_i                          (Branch_id2dff             ),
    .MemRead_i                         (MemRead_id2dff            ),
    .MemWrite_i                        (MemWrite_id2dff           ),
    .RegWrite_i                        (RegWrite_id2dff           ),
    .MemtoReg_i                        (MemtoReg_id2dff           ),
    //----------------------------output----------------------------
    .instruction_addr_o                (instruction_addr_dff2ex   ),
    .rs1_rdata_o                       (rs1_rdata_dff2ex          ),
    .rs2_rdata_o                       (rs2_rdata_dff2ex          ),
    .imm_gen_o                         (imm_gen_dff2ex            ),
    .rd_o                              (rd_dff2ex                 ),
    .ALU_ctrl_o                        (ALU_ctrl_dff2ex           ),
    .rs1_o                             (rs1_dff2fu                ),
    .rs2_o                             (rs2_dff2fu                ),
    .ALUSrc_o                          (ALUSrc_dff2ex             ),
    .ALUOp_o                           (ALUOp_dff2ex              ),
    .Branch_o                          (Branch_dff2ex             ),
    .MemRead_o                         (MemRead_dff2ex            ),
    .MemWrite_o                        (MemWrite_dff2ex           ),
    .RegWrite_o                        (RegWrite_dff2ex           ),
    .MemtoReg_o                        (MemtoReg_dff2ex           ) 
  );
//---------------------------------------------------------------------
// EX
//---------------------------------------------------------------------
execute  execute_inst (
    //----------------------------input-----------------------------
    .instruction_addr_i                (instruction_addr_dff2ex   ),
    .rs1_rdata_i                       (rs1_rdata_dff2ex          ),
    .rs2_rdata_i                       (rs2_rdata_dff2ex          ),
    .imm_gen_i                         (imm_gen_dff2ex            ),
    .rd_i                              (rd_dff2ex                 ),
    .ALU_ctrl_i                        (ALU_ctrl_dff2ex           ),
    .ALUSrc_i                          (ALUSrc_dff2ex             ),
    .ALUOp_i                           (ALUOp_dff2ex              ),
    .Branch_i                          (Branch_dff2ex             ),
    .MemRead_i                         (MemRead_dff2ex            ),
    .MemWrite_i                        (MemWrite_dff2ex           ),
    .RegWrite_i                        (RegWrite_dff2ex           ),
    .MemtoReg_i                        (MemtoReg_dff2ex           ),
    .ForwardA_i                        (ForwardA_fu2ex            ),
    .ForwardB_i                        (ForwardB_fu2ex            ),
    .WB_rd_wdata_i                     (rd_wdata_wb2id            ),
    .MEM_alu_result_i                  (alu_result_mem2dff        ),
    .PCSrc_i                           (PCSrc_mem2if              ),
    //----------------------------output----------------------------
    .rs2_rdata_o                       (rs2_rdata_ex2dff          ),
    .alu_result_o                      (alu_result_ex2dff         ),
    .condition_en_o                    (condition_en_ex2dff       ),
    .instruction_addr_o                (instruction_addr_ex2dff   ),
    .rd_o                              (rd_ex2dff                 ),
    .RegWrite_o                        (RegWrite_ex2dff           ),
    .MemtoReg_o                        (MemtoReg_ex2dff           ),
    .Branch_o                          (Branch_ex2dff             ),
    .MemRead_o                         (MemRead_ex2dff            ),
    .MemWrite_o                        (MemWrite_ex2dff           ) 
  );
//---------------------------------------------------------------------
// EX_MEM
//---------------------------------------------------------------------
execute2memory  execute2memory_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .rs2_rdata_i                       (rs2_rdata_ex2dff          ),
    .alu_result_i                      (alu_result_ex2dff         ),
    .condition_en_i                    (condition_en_ex2dff       ),
    .instruction_addr_i                (instruction_addr_ex2dff   ),
    .rd_i                              (rd_ex2dff                 ),
    .RegWrite_i                        (RegWrite_ex2dff           ),
    .MemtoReg_i                        (MemtoReg_ex2dff           ),
    .Branch_i                          (Branch_ex2dff             ),
    .MemRead_i                         (MemRead_ex2dff            ),
    .MemWrite_i                        (MemWrite_ex2dff           ),
    //----------------------------output----------------------------
    .rs2_rdata_o                       (rs2_rdata_dff2mem         ),
    .alu_result_o                      (alu_result_dff2mem        ),
    .condition_en_o                    (condition_en_dff2mem      ),
    .instruction_addr_o                (instruction_addr_dff2mem  ),
    .rd_o                              (rd_dff2mem                ),
    .RegWrite_o                        (RegWrite_dff2mem          ),
    .MemtoReg_o                        (MemtoReg_dff2mem          ),
    .Branch_o                          (Branch_dff2mem            ),
    .MemRead_o                         (MemRead_dff2mem           ),
    .MemWrite_o                        (MemWrite_dff2mem          ) 
  );
//---------------------------------------------------------------------
// MEM
//---------------------------------------------------------------------
memory  memory_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .rs2_rdata_i                       (rs2_rdata_dff2mem         ),
    .alu_result_i                      (alu_result_dff2mem        ),
    .condition_en_i                    (condition_en_dff2mem      ),
    .instruction_addr_i                (instruction_addr_dff2mem  ),
    .rd_i                              (rd_dff2mem                ),
    .RegWrite_i                        (RegWrite_dff2mem          ),
    .MemtoReg_i                        (MemtoReg_dff2mem          ),
    .Branch_i                          (Branch_dff2mem            ),
    .MemRead_i                         (MemRead_dff2mem           ),
    .MemWrite_i                        (MemWrite_dff2mem          ),
    //----------------------------output----------------------------
    .instruction_addr_o                (instruction_addr_mem2if   ),
    .PCSrc_o                           (PCSrc_mem2if              ),
    .DM_rd_data_o                      (DM_rd_data_mem2dff        ),
    .alu_result_o                      (alu_result_mem2dff        ),
    .RegWrite_o                        (RegWrite_mem2dff          ),
    .MemtoReg_o                        (MemtoReg_mem2dff          ),
    .rd_o                              (rd_mem2dff                ),

    .rd_en_i                           (rd_en_i                   ),
    .rd_addr_i                         (rd_addr_i                 ),
    .rd_data_o                         (rd_data_o                 ) 
  );
//---------------------------------------------------------------------
// MEM_WB
//---------------------------------------------------------------------
memory2write_back  memory2write_back_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //----------------------------input-----------------------------
    .DM_rd_data_i                      (DM_rd_data_mem2dff        ),
    .alu_result_i                      (alu_result_mem2dff        ),
    .RegWrite_i                        (RegWrite_mem2dff          ),
    .MemtoReg_i                        (MemtoReg_mem2dff          ),
    .rd_i                              (rd_mem2dff                ),
    //----------------------------output----------------------------
    .DM_rd_data_o                      (DM_rd_data_dff2wb         ),
    .alu_result_o                      (alu_result_dff2wb         ),
    .RegWrite_o                        (RegWrite_dff2wb           ),
    .MemtoReg_o                        (MemtoReg_dff2wb           ),
    .rd_o                              (rd_dff2wb                 ) 
  );
//---------------------------------------------------------------------
// WB
//---------------------------------------------------------------------
write_back  write_back_inst (
    //----------------------------input-----------------------------
    .DM_rd_data_i                      (DM_rd_data_dff2wb         ),
    .alu_result_i                      (alu_result_dff2wb         ),
    .RegWrite_i                        (RegWrite_dff2wb           ),
    .MemtoReg_i                        (MemtoReg_dff2wb           ),
    .rd_i                              (rd_dff2wb                 ),
    //----------------------------output----------------------------
    .rd_wr_en_o                        (rd_wr_en_wb2id            ),
    .rd_waddr_o                        (rd_waddr_wb2id            ),
    .rd_wdata_o                        (rd_wdata_wb2id            ) 
  );
//---------------------------------------------------------------------
// forwarding_unit
//---------------------------------------------------------------------
forwarding_unit  forwarding_unit_inst (
    //----------------------------input-----------------------------
    .rs1_i                             (rs1_dff2fu                ),
    .rs2_i                             (rs2_dff2fu                ),
    .EX_MEM_rd_i                       (rd_mem2dff                ),
    .MEM_WB_rd_i                       (rd_dff2wb                 ),
    .EX_MEM_RegWrite_i                 (RegWrite_mem2dff          ),
    .MEM_WB_RegWrite_i                 (RegWrite_dff2wb           ),
    //----------------------------output----------------------------
    .ForwardA_o                        (ForwardA_fu2ex            ),
    .ForwardB_o                        (ForwardB_fu2ex            ) 
  );
//---------------------------------------------------------------------
// hazard_detection_unit
//---------------------------------------------------------------------
hazard_detection_unit  hazard_detection_unit_inst (
    //----------------------------input-----------------------------
    .ID_EX_MemRead_i                   (MemRead_dff2ex            ),
    .rs1_i                             (rs1_id2dff                ),
    .rs2_i                             (rs2_id2dff                ),
    .ID_EX_rd_i                        (rd_dff2ex                 ),
    //----------------------------output----------------------------
    .stall_en_o                        (stall_en                  ) 
  );
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// IF(取指)
//---------------------------------------------------------------------
module instruction_fetch (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    
    input  wire                         PCSrc_i                    ,
    input  wire        [  31:0]         instruction_addr_i         ,
    // from hazard_detection_unit
    input  wire                         stall_en_i                 ,
    // from ID
    input  wire        [  31:0]         jump_addr_i                ,
    input  wire                         jump_en_i                  ,
    // to ID
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         instruction_o               
);
reg                    [  31:0]         pc_r                       ;
wire                   [  31:0]         pc_add                     ;
wire                   [  31:0]         pc                         ;
wire                   [  31:0]         instruction_r              ;

assign instruction_addr_o = pc_r;
assign instruction_o = (PCSrc_i||jump_en_i)? `INST_NOP:
                            (stall_en_i)? `INST_NOP:instruction_r;
assign pc_add = pc_r + 32'd4;

assign pc = (jump_en_i)? jump_addr_i:
                (PCSrc_i)? instruction_addr_i:pc_add;

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        pc_r <= 32'd0;
    else if (stall_en_i)
        pc_r <= pc_r;
    else
        pc_r <= pc;
end

instruction_memory instruction_memory_inst(
    // from pc
    .instruction_addr_i                (pc_r                      ),
    // to ID
    .instruction_o                     (instruction_r             ) 
);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// IF_ID
//---------------------------------------------------------------------
module instruction_fetch2instruction_decode (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from IF
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [  31:0]         instruction_i              ,//from IF
    //to ID
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         instruction_o               //to ID
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,`INST_NOP,instruction_i,instruction_o);//Delay_flip_flop default to INST_NOP
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);//Data_flip_flop
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ID(指令译码和读寄存器堆)
//---------------------------------------------------------------------
module instruction_decode (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    // from wb , to regs
    input  wire                         rd_wr_en_i                 ,
    input  wire        [   4:0]         rd_waddr_i                 ,
    input  wire        [  31:0]         rd_wdata_i                 ,
    // from IF
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [  31:0]         instruction_i              ,//from IF
    // from hazard_detection_unit
    input  wire                         stall_en_i                 ,
    input  wire                         PCSrc_i                    ,
    // to EX
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         rs1_rdata_o                ,//from register source1 rd data
    output wire        [  31:0]         rs2_rdata_o                ,//from register source2 rd data
    output reg         [  31:0]         imm_gen_o                  ,//generated immediate data
    output wire        [   4:0]         rd_o                       ,//register destination
    output wire        [   3:0]         ALU_ctrl_o                 ,

    output wire        [   4:0]         rs1_o                      ,//register source1
    output wire        [   4:0]         rs2_o                      ,//register source2
    //EX ctrl
    output reg                          ALUSrc_o                   ,//openning means inst_addr to no +4 
    output reg         [   1:0]         ALUOp_o                    ,
    //MEM ctrl
    output reg                          Branch_o                   ,
    output wire                         MemRead_o                  ,
    output wire                         MemWrite_o                 ,
    //WB ctrl
    output reg                          RegWrite_o                 ,
    output reg                          MemtoReg_o                 ,

    // to IF
    output reg         [  31:0]         jump_addr_o                ,
    output reg                          jump_en_o                   
);
//
reg                                     rd_wr_en_r                 ;
reg                    [  31:0]         rd_wdata_r                 ;

wire                   [  31:0]         instruction_r              ;

// decode
wire                   [   6:0]         opcode                     ;
wire                   [   2:0]         func3                      ;
wire                   [   6:0]         func7                      ;//function
wire                   [  11:0]         imm_i                      ;//immediate data i 类
wire                   [  11:0]         imm_s                      ;//immediate data s or b
wire                   [  19:0]         imm_u                      ;//immediate data u

// to registers 
wire                   [   4:0]         rs1_raddr_r                ;//register source1 address
wire                   [   4:0]         rs2_raddr_r                ;//register source2 address
// from registers 
wire                   [  31:0]         rs1_rdata_r                ;//register source1 address
wire                   [  31:0]         rs2_rdata_r                ;//register source2 address

// detection
reg                                     MemRead_r                  ;
reg                                     MemWrite_r                 ;

assign instruction_r = (PCSrc_i)? `INST_NOP:instruction_i;

// decode
assign opcode = instruction_r[6:0];                                 //操作码
assign rd_o   = instruction_r[11:7];                                //设置目的寄存器地址
assign func3  = instruction_r[14:12];
assign rs1_o  = (rd_wr_en_r)? 32'd0:instruction_r[19:15];           //源寄存器1
assign rs2_o  = (rd_wr_en_r)? 32'd0:instruction_r[24:20];           //源寄存器2
assign func7  = instruction_r[31:25];
assign imm_i  = instruction_r[31:20];

assign imm_s = {instruction_r[31:25],instruction_r[11:7]};

assign imm_u  = instruction_r[31:12];

assign instruction_addr_o = instruction_addr_i;
assign ALU_ctrl_o = {instruction_r[30],instruction_r[14:12]};

assign rs1_raddr_r = rs1_o;                                         //从寄存器堆取出地址为rs1的数
assign rs1_rdata_o = (rd_wr_en_r)? rd_wdata_r:rs1_rdata_r;
assign rs2_raddr_r = rs2_o;                                         //从寄存器堆取出地址为rs2的数
assign rs2_rdata_o = (rd_wr_en_r)? 32'd0:rs2_rdata_r;

assign MemRead_o = (stall_en_i)? 1'b0 : MemRead_r;
assign MemWrite_o = (stall_en_i)? 1'b0 : MemWrite_r;

// control(控制器)
always@(*)begin
    case (opcode)
        //command : INST_TYPE_I
        `INST_TYPE_I: begin                                         //I型指令
            case (func3)
                `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI,`INST_SLLI,`INST_SRI: begin
                    imm_gen_o = {{20{imm_i[11]}},imm_i};            //为需要产生的立即数，[11:0]12位,且需要进行符号位扩展
                    //EX ctrl
                    ALUSrc_o   = 1'b1;
                    ALUOp_o    = 2'b10;                             //表明由func3和func7决定
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd1;
                    MemtoReg_o = 1'd0;
                end
                default: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
            endcase
        end
        //command : INST_TYPE_R_M
        `INST_TYPE_R_M: begin                                       //R型指令
            case (func3)
                `INST_ADD_SUB,`INST_SLL,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_SR,`INST_OR,`INST_AND: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b10;                             //表明由func3和func7决定
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd1;                              //operate rd then this signal open
                    MemtoReg_o = 1'd0;
                end
                default: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
            endcase
        end
        //command : INST_TYPE_L
        `INST_TYPE_L: begin
            case (func3)
                `INST_LB,`INST_LH,`INST_LW,`INST_LBU,`INST_LHU: begin
                    imm_gen_o = {{20{imm_i[11]}},imm_i};
                    //EX ctrl
                    ALUSrc_o   = 1'b1;
                    ALUOp_o    = 2'b00;                             //加法
                    //MEM ctrl
                    Branch_o   = 1'd0;                              //choose pc from immx2 or +4
                    MemRead_r  = 1'd1;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd1;
                    MemtoReg_o = 1'd1;
                end
                default: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
            endcase
        end
        //commadn : INST_TYPE_S
        `INST_TYPE_S: begin
            case (func3)
                `INST_SB,`INST_SH,`INST_SW: begin
                    imm_gen_o = imm_s;
                    //EX ctrl
                    ALUSrc_o   = 1'b1;
                    ALUOp_o    = 2'b00;                             //加法
                    //MEM ctrl
                    Branch_o   = 1'd0;                              //choose pc from immx2 or +4
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd1;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
                default: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
            endcase
        end
        //commadn : INST_TYPE_B
        `INST_TYPE_B: begin
            case (func3)
                `INST_BEQ,`INST_BNE,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU: begin
                    imm_gen_o = {{20{imm_s[11]}},imm_s[11],imm_s[0],imm_s[10:5],imm_s[4:1]};//先不移位,EX再移位
                    //EX ctrl
                    ALUSrc_o   = 1'b0;                              //choose alu_data2 from imm or rs2
                    ALUOp_o    = 2'b01;                             //减法
                    //MEM ctrl
                    Branch_o   = 1'd1;                              //choose pc from immx2 or +4
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
                default: begin
                    imm_gen_o = 32'd0;
                    //EX ctrl
                    ALUSrc_o   = 1'b0;
                    ALUOp_o    = 2'b00;
                    //MEM ctrl
                    Branch_o   = 1'd0;
                    MemRead_r  = 1'd0;
                    MemWrite_r = 1'd0;
                    //WB ctrl
                    RegWrite_o = 1'd0;
                    MemtoReg_o = 1'd0;
                end
            endcase
        end
        //command : INST_JAL
        `INST_JAL,`INST_JALR,`INST_LUI,`INST_AUIPC: begin
            imm_gen_o = 32'd0;
            //EX ctrl
            ALUSrc_o   = 1'b0;                                      //choose alu_data2 from imm or rs2
            ALUOp_o    = 2'b00;                                     //加法
            //MEM ctrl
            Branch_o   = 1'd0;                                      //choose pc from immx2 or +4
            MemRead_r  = 1'd0;
            MemWrite_r = 1'd0;
            //WB ctrl
            RegWrite_o = 1'd1;
            MemtoReg_o = 1'd0;
        end
        default: begin
            imm_gen_o = 32'd0;
            //EX ctrl
            ALUSrc_o   = 1'b0;
            ALUOp_o    = 2'b00;
            //MEM ctrl
            Branch_o   = 1'd0;
            MemRead_r  = 1'd0;
            MemWrite_r = 1'd0;
            //WB ctrl
            RegWrite_o = 1'd0;
            MemtoReg_o = 1'd0;
        end
    endcase
end

always@(*)begin
    case (opcode)
        //command : INST_JAL
        `INST_JAL: begin
            jump_addr_o = instruction_addr_i + {{11{imm_u[19]}},imm_u[19],imm_u[7:0],imm_u[8],imm_u[18:9],1'b0};
            jump_en_o = 1'd1;

            rd_wdata_r = instruction_addr_i + 32'd4;
            rd_wr_en_r = 1'd1;
        end
        //command : INST_JALR
        `INST_JALR: begin
            jump_addr_o = rs1_rdata_r + {{19{imm_i[11]}},imm_i,1'b0};
            jump_en_o = 1'd1;

            rd_wdata_r = instruction_addr_i + 32'd4;
            rd_wr_en_r = 1'd1;
        end
        //command : INST_LUI
        `INST_LUI: begin
            jump_addr_o = 32'd0;
            jump_en_o = 1'd0;

            rd_wdata_r = {{12{imm_u[19]}},imm_u} << 12;
            rd_wr_en_r = 1'd1;
        end
        //command : INST_AUIPC
        `INST_AUIPC: begin
            jump_addr_o = 32'd0;
            jump_en_o = 1'd0;

            rd_wdata_r = instruction_addr_i + {{{12{imm_u[19]}},imm_u} << 12};
            rd_wr_en_r = 1'd1;
        end
        default: begin
            jump_addr_o = 32'd0;
            jump_en_o = 1'd0;
            
            rd_wdata_r = 32'd0;
            rd_wr_en_r = 1'd0;
        end
    endcase
end

registers registers_inst(
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    //from id
    .rs1_raddr_i                       (rs1_raddr_r               ),
    .rs2_raddr_i                       (rs2_raddr_r               ),
	//to id
    .rs1_rdata_o                       (rs1_rdata_r               ),
    .rs2_rdata_o                       (rs2_rdata_r               ),
	//from ex
    .rd_waddr_i                        (rd_waddr_i                ),
    .rd_wdata_i                        (rd_wdata_i                ),
    .rd_wr_en_i                        (rd_wr_en_i                ) 
);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ID_EX
//---------------------------------------------------------------------
module instruction_decode2execute (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    // from ID
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [  31:0]         rs1_rdata_i                ,//from register source1 rd data
    input  wire        [  31:0]         rs2_rdata_i                ,//from register source2 rd data
    input  wire        [  31:0]         imm_gen_i                  ,//generated immediate data
    input  wire        [   4:0]         rd_i                       ,//register destination
    input  wire        [   3:0]         ALU_ctrl_i                 ,

    input  wire        [   4:0]         rs1_i                      ,
    input  wire        [   4:0]         rs2_i                      ,
    //EX ctrl
    input  wire                         ALUSrc_i                   ,
    input  wire        [   1:0]         ALUOp_i                    ,
    //MEM ctrl
    input  wire                         Branch_i                   ,
    input  wire                         MemRead_i                  ,
    input  wire                         MemWrite_i                 ,
    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,

    // to EX
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         rs1_rdata_o                ,//from register source1 rd data
    output wire        [  31:0]         rs2_rdata_o                ,//from register source2 rd data
    output wire        [  31:0]         imm_gen_o                  ,//generated immediate data
    output wire        [   4:0]         rd_o                       ,//register destination
    output wire        [   3:0]         ALU_ctrl_o                 ,

    output wire        [   4:0]         rs1_o                      ,
    output wire        [   4:0]         rs2_o                      ,
    //EX ctrl
    output wire                         ALUSrc_o                   ,
    output wire        [   1:0]         ALUOp_o                    ,
    //MEM ctrl
    output wire                         Branch_o                   ,
    output wire                         MemRead_o                  ,
    output wire                         MemWrite_o                 ,
    //WB ctrl
    output wire                         RegWrite_o                 ,
    output wire                         MemtoReg_o                  
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,rs1_rdata_i,rs1_rdata_o);
dff_sync #(32) dff3(sys_clk_i,rst_n_i,32'd0,rs2_rdata_i,rs2_rdata_o);
dff_sync #(32) dff4(sys_clk_i,rst_n_i,32'd0,imm_gen_i,imm_gen_o);
dff_sync #(5) dff5(sys_clk_i,rst_n_i,5'd0,rd_i,rd_o);
dff_sync #(4) dff6(sys_clk_i,rst_n_i,4'd0,ALU_ctrl_i,ALU_ctrl_o);

dff_sync #(5) dff7(sys_clk_i,rst_n_i,5'd0,rs1_i,rs1_o);
dff_sync #(5) dff8(sys_clk_i,rst_n_i,5'd0,rs2_i,rs2_o);
    //EX ctrl
dff_sync #(1) dff9(sys_clk_i,rst_n_i,1'd0,ALUSrc_i,ALUSrc_o);
dff_sync #(2) dff10(sys_clk_i,rst_n_i,2'd0,ALUOp_i,ALUOp_o);
    //MEM ctrl
dff_sync #(1) dff11(sys_clk_i,rst_n_i,1'd0,Branch_i,Branch_o);
dff_sync #(1) dff12(sys_clk_i,rst_n_i,1'd0,MemRead_i,MemRead_o);
dff_sync #(1) dff13(sys_clk_i,rst_n_i,1'd0,MemWrite_i,MemWrite_o);
    //WB ctrl
dff_sync #(1) dff14(sys_clk_i,rst_n_i,1'd0,RegWrite_i,RegWrite_o);
dff_sync #(1) dff15(sys_clk_i,rst_n_i,1'd0,MemtoReg_i,MemtoReg_o);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// EX(执行或者计算地址)
//---------------------------------------------------------------------
module execute (
    // from ID
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [  31:0]         rs1_rdata_i                ,//from register source1 rd data
    input  wire        [  31:0]         rs2_rdata_i                ,//from register source2 rd data
    input  wire        [  31:0]         imm_gen_i                  ,//generated immediate data
    input  wire        [   4:0]         rd_i                       ,//register destination
    input  wire        [   3:0]         ALU_ctrl_i                 ,

    //EX ctrl
    input  wire                         ALUSrc_i                   ,
    input  wire        [   1:0]         ALUOp_i                    ,
    //MEM ctrl
    input  wire                         Branch_i                   ,
    input  wire                         MemRead_i                  ,//load
    input  wire                         MemWrite_i                 ,
    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,

    // from forward_unit
    input  wire        [   1:0]         ForwardA_i                 ,
    input  wire        [   1:0]         ForwardB_i                 ,
    input  wire        [  31:0]         WB_rd_wdata_i              ,
    input  wire        [  31:0]         MEM_alu_result_i           ,

    input  wire                         PCSrc_i                    ,

    // to MEM
    output wire        [  31:0]         rs2_rdata_o                ,
    output reg         [  31:0]         alu_result_o               ,//calculate
    output reg                          condition_en_o             ,//if ? condition
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [   4:0]         rd_o                       ,//register destination

    //WB ctrl
    output wire                         RegWrite_o                 ,
    output wire                         MemtoReg_o                 ,
    //MEM ctrl
    output wire                         Branch_o                   ,
    output wire                         MemRead_o                  ,
    output wire                         MemWrite_o                  
);

reg                    [  31:0]         alu_data1                  ;
reg                    [  31:0]         alu_data2_r                ;//alu2 first mux
wire                   [  31:0]         alu_data2                  ;//alu2 second mux
wire                   [  31:0]         alu_data2_shift1           ;
    //WB ctrl
assign RegWrite_o = (PCSrc_i)? 1'b0:RegWrite_i;
assign MemtoReg_o = (PCSrc_i)? 1'b0:MemtoReg_i;
    //MEM ctrl
assign Branch_o = (PCSrc_i)? 1'b0:Branch_i;
assign MemRead_o = (PCSrc_i)? 1'b0:MemRead_i;
assign MemWrite_o = (PCSrc_i)? 1'b0:MemWrite_i;

assign alu_data2 = (ALUSrc_i)? imm_gen_i : alu_data2_r;
assign alu_data2_shift1 = imm_gen_i << 1;                           //地址偏移x2

assign instruction_addr_o = instruction_addr_i + alu_data2_shift1;
assign rs2_rdata_o = alu_data2_r;
assign rd_o = rd_i;

always@(*)begin
    case (ForwardA_i)
        2'b10: alu_data1 = MEM_alu_result_i;
        2'b01: alu_data1 = WB_rd_wdata_i;
        default: alu_data1 = rs1_rdata_i;
    endcase
end

always@(*)begin
    case (ForwardB_i)
        2'b10: alu_data2_r = MEM_alu_result_i;
        2'b01: alu_data2_r = WB_rd_wdata_i;
        default: alu_data2_r = rs2_rdata_i;
    endcase
end

//ALU control
always@(*)begin
    case (ALUOp_i)
        2'b00: alu_result_o = alu_data1 + alu_data2;                //load or store
        2'b10: begin
            case (ALU_ctrl_i[2:0])
                {3'b000}: begin
                    case ({ALUSrc_i,ALU_ctrl_i[3]})
                        2'b01: alu_result_o = alu_data1 - alu_data2;//INST_ADD_SUB or INST_ADDI
                        default: alu_result_o = alu_data1 + alu_data2;
                    endcase
                end
                {3'b010}: alu_result_o = ($signed(alu_data1) < $signed(alu_data2))? 32'd1:32'd0;//INST_SLT or INST_SLTI
                {3'b011}: alu_result_o = (alu_data1 < alu_data2)? 32'd1:32'd0;//INST_SLTIU or INST_SLTU
                {3'b100}: alu_result_o = alu_data1 ^ alu_data2;
                {3'b110}: alu_result_o = alu_data1 | alu_data2;
                {3'b111}: alu_result_o = alu_data1 & alu_data2;
                {3'b001}: alu_result_o = alu_data1 << alu_data2;    //INST_SLL or 
                {3'b101}: begin
                    case (ALU_ctrl_i[3])
                        1'b1: alu_result_o = $signed(alu_data1) >>> alu_data2[4:0];//>>>表示,对于有符号数,用符号位填充
                        default: alu_result_o = alu_data1 >> alu_data2[4:0];//右移,补0
                    endcase
                end
                default: alu_result_o = 32'd0;
            endcase
        end
        2'b11: alu_result_o = instruction_addr_i + 32'd4;           //jar
        default: alu_result_o = 32'd0;
    endcase
end

always@(*)begin
    case (ALUOp_i)
        2'b01: begin
            case (ALU_ctrl_i[2:0])
                `INST_BEQ: condition_en_o = (alu_data1 == alu_data2)? 1'b1:1'b0;
                `INST_BNE: condition_en_o = (alu_data1 != alu_data2)? 1'b1:1'b0;
                `INST_BLT: condition_en_o = ($signed(alu_data1) < $signed(alu_data2))? 1'b1:1'b0;
                `INST_BGE: condition_en_o = ($signed(alu_data1) >= $signed(alu_data2))? 1'b1:1'b0;
                `INST_BLTU: condition_en_o = (alu_data1 < alu_data2)? 1'b1:1'b0;
                `INST_BGEU: condition_en_o = (alu_data1 >= alu_data2)? 1'b1:1'b0;
                default: condition_en_o = 1'b0;
            endcase
        end
        default: condition_en_o = 1'b0;
    endcase
end
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// EX_MEM
//---------------------------------------------------------------------
module execute2memory (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    // from EX
    input  wire        [  31:0]         rs2_rdata_i                ,
    input  wire        [  31:0]         alu_result_i               ,//calculate
    input  wire                         condition_en_i             ,//if ? condition
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [   4:0]         rd_i                       ,//register destination

    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,
    //MEM ctrl
    input  wire                         Branch_i                   ,
    input  wire                         MemRead_i                  ,
    input  wire                         MemWrite_i                 ,
    // to MEM
    output wire        [  31:0]         rs2_rdata_o                ,
    output wire        [  31:0]         alu_result_o               ,//calculate
    output wire                         condition_en_o             ,//if ? condition
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [   4:0]         rd_o                       ,//register destination

    //WB ctrl
    output wire                         RegWrite_o                 ,
    output wire                         MemtoReg_o                 ,
    //MEM ctrl
    output wire                         Branch_o                   ,
    output wire                         MemRead_o                  ,
    output wire                         MemWrite_o                  
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,32'd0,rs2_rdata_i,rs2_rdata_o);
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,alu_result_i,alu_result_o);
dff_sync #(1) dff3(sys_clk_i,rst_n_i,1'd0,condition_en_i,condition_en_o);
dff_sync #(32) dff4(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);
dff_sync #(5) dff5(sys_clk_i,rst_n_i,5'd0,rd_i,rd_o);
    //MEM ctrl
dff_sync #(1) dff6(sys_clk_i,rst_n_i,1'd0,Branch_i,Branch_o);
dff_sync #(1) dff7(sys_clk_i,rst_n_i,1'd0,MemRead_i,MemRead_o);
dff_sync #(1) dff8(sys_clk_i,rst_n_i,1'd0,MemWrite_i,MemWrite_o);
    //WB ctrl
dff_sync #(1) dff9(sys_clk_i,rst_n_i,1'd0,RegWrite_i,RegWrite_o);
dff_sync #(1) dff10(sys_clk_i,rst_n_i,1'd0,MemtoReg_i,MemtoReg_o);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// MEM(数据存储器访问)
//---------------------------------------------------------------------
module memory (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    // from EX
    input  wire        [  31:0]         rs2_rdata_i                ,
    input  wire        [  31:0]         alu_result_i               ,//calculate
    input  wire                         condition_en_i             ,//if ? condition
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [   4:0]         rd_i                       ,//register destination

    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,
    //MEM ctrl
    input  wire                         Branch_i                   ,
    input  wire                         MemRead_i                  ,
    input  wire                         MemWrite_i                 ,

    //
    output wire        [  31:0]         instruction_addr_o         ,
    output wire                         PCSrc_o                    ,
    output wire        [  31:0]         DM_rd_data_o               ,
    output wire        [  31:0]         alu_result_o               ,//calculate
    //WB ctrl
    output wire                         RegWrite_o                 ,
    output wire                         MemtoReg_o                 ,
    output wire        [   4:0]         rd_o                       ,

    //to top
    input  wire                         rd_en_i                    ,
    input  wire        [  31:0]         rd_addr_i                  ,
    output wire        [  31:0]         rd_data_o                   
);

assign alu_result_o = alu_result_i;
assign instruction_addr_o = instruction_addr_i;
assign PCSrc_o = Branch_i & condition_en_i;
assign RegWrite_o = RegWrite_i;
assign MemtoReg_o = MemtoReg_i;
assign rd_o = rd_i;

data_memory data_memory_inst(
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    
    .dm_wr_en_i                        (MemWrite_i                ),
    .dm_wdata_i                        (rs2_rdata_i               ),

    .dm_addr_i                         (alu_result_i              ),

    .dm_rd_en_i                        (MemRead_i                 ),
    .dm_rdata_o                        (DM_rd_data_o              ),

    .rd_en_i                           (rd_en_i                   ),
    .rd_addr_i                         (rd_addr_i                 ),
    .rd_data_o                         (rd_data_o                 ) 
);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// MEM_WB
//---------------------------------------------------------------------
module memory2write_back (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from MEM
    input  wire        [  31:0]         DM_rd_data_i               ,
    input  wire        [  31:0]         alu_result_i               ,//calculate
    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,
    input  wire        [   4:0]         rd_i                       ,
    //
    output wire        [  31:0]         DM_rd_data_o               ,
    output wire        [  31:0]         alu_result_o               ,//calculate
    //WB ctrl
    output wire                         RegWrite_o                 ,
    output wire                         MemtoReg_o                 ,
    output wire        [   4:0]         rd_o                        
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,32'd0,DM_rd_data_i,DM_rd_data_o);
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,alu_result_i,alu_result_o);
dff_sync #(1) dff3(sys_clk_i,rst_n_i,1'd0,RegWrite_i,RegWrite_o);
dff_sync #(1) dff4(sys_clk_i,rst_n_i,1'd0,MemtoReg_i,MemtoReg_o);
dff_sync #(5) dff5(sys_clk_i,rst_n_i,5'd0,rd_i,rd_o);
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// WB
//---------------------------------------------------------------------
module write_back (
    //from MEM

    input  wire        [  31:0]         DM_rd_data_i               ,
    input  wire        [  31:0]         alu_result_i               ,//calculate
    //WB ctrl
    input  wire                         RegWrite_i                 ,
    input  wire                         MemtoReg_i                 ,
    input  wire        [   4:0]         rd_i                       ,

    output wire        [  31:0]         rd_wdata_o                 ,
    output wire                         rd_wr_en_o                 ,
    output wire        [   4:0]         rd_waddr_o                  
);
    
assign rd_wdata_o = (MemtoReg_i)? DM_rd_data_i:alu_result_i;
assign rd_wr_en_o = RegWrite_i;
assign rd_waddr_o = rd_i;
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// forwarding_unit(前递)
//---------------------------------------------------------------------
module forwarding_unit (
    input  wire        [   4:0]         rs1_i                      ,
    input  wire        [   4:0]         rs2_i                      ,
    input  wire        [   4:0]         EX_MEM_rd_i                ,
    input  wire        [   4:0]         MEM_WB_rd_i                ,

    input  wire                         EX_MEM_RegWrite_i          ,
    input  wire                         MEM_WB_RegWrite_i          ,

    output reg         [   1:0]         ForwardA_o                 ,
    output reg         [   1:0]         ForwardB_o                  
);

always@(*)begin
    if (EX_MEM_RegWrite_i && EX_MEM_rd_i != 5'd0 && EX_MEM_rd_i == rs1_i)
        ForwardA_o = 2'b10;
    else if (MEM_WB_RegWrite_i && MEM_WB_rd_i != 5'd0 && MEM_WB_rd_i == rs1_i)
        ForwardA_o = 2'b01;
    else
        ForwardA_o = 2'b00;
end

always@(*)begin
    if (EX_MEM_RegWrite_i && EX_MEM_rd_i != 5'd0 && EX_MEM_rd_i == rs2_i)
        ForwardB_o = 2'b10;
    else if (MEM_WB_RegWrite_i && MEM_WB_rd_i != 5'd0 && MEM_WB_rd_i == rs2_i)
        ForwardB_o = 2'b01;
    else
        ForwardB_o = 2'b00;
end
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// hazard_detection_unit(冒险保护)
//---------------------------------------------------------------------
module hazard_detection_unit (
    input                               ID_EX_MemRead_i            ,
    input              [   4:0]         rs1_i                      ,
    input              [   4:0]         rs2_i                      ,
    input              [   4:0]         ID_EX_rd_i                 ,

    output wire                         stall_en_o                  
);
assign stall_en_o = (ID_EX_MemRead_i && (ID_EX_rd_i == rs1_i || ID_EX_rd_i == rs2_i))? 1'b1:1'b0;
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// INST_MEM(指令存储器)
//---------------------------------------------------------------------
module instruction_memory (
    input  wire        [  31:0]         instruction_addr_i         ,
    output wire        [  31:0]         instruction_o               
);
reg                    [  31:0]         rom_memo[0:4095]           ;//4096 32bits
assign instruction_o = rom_memo[instruction_addr_i>>2];
// integer n;

// initial begin
//     $readmemb("E:/risc_v_project/rtl/module/123.bin",rom_memo);
//     for (n = 0;n<=4095; n=n+1) begin
//         $display("%b",rom_memo[n]);
//     end
// end

endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// REGS(寄存器堆)
//---------------------------------------------------------------------
module registers (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from id
    input  wire        [   4:0]         rs1_raddr_i                ,
    input  wire        [   4:0]         rs2_raddr_i                ,
	//to id
    output reg         [  31:0]         rs1_rdata_o                ,
    output reg         [  31:0]         rs2_rdata_o                ,
	//from ex
    input  wire        [   4:0]         rd_waddr_i                 ,
    input  wire        [  31:0]         rd_wdata_i                 ,
    input  wire                         rd_wr_en_i                  
);
//一共有x0~x31一共32个寄存器,加上一个rdata
reg                    [  31:0]         r_regs[0:31]               ;//32 32bits

integer i;
//rs1
always @(*)begin
    if(rst_n_i == 1'b0)
        rs1_rdata_o <= 32'b0;
    else if(rs1_raddr_i == 5'b0)
        rs1_rdata_o <= 32'b0;
    else if(rd_wr_en_i && rs1_raddr_i == rd_waddr_i)                //指令冲突
        rs1_rdata_o <= rd_wdata_i;
    else
        rs1_rdata_o <= r_regs[rs1_raddr_i];                         //一直给rs1赋值
end
//rs2
always @(*)begin
    if(rst_n_i == 1'b0)
        rs2_rdata_o <= 32'b0;
    else if(rs2_raddr_i == 5'b0)                                    //置零
        rs2_rdata_o <= 32'b0;
    else if(rd_wr_en_i && rs2_raddr_i == rd_waddr_i)                //指令冲突
        rs2_rdata_o <= rd_wdata_i;
    else
        rs2_rdata_o <= r_regs[rs2_raddr_i];                         //一直给r2赋值
end
//该部分打拍相当于回写之后的目标自己的寄存器
always @(posedge sys_clk_i)begin
    if(!rst_n_i) begin
        for(i=0;i<32;i=i+1)begin
            r_regs[i] <= 32'b0;
        end
    end
    else if(rd_wr_en_i && rd_waddr_i != 5'b0)begin                  //相当于永远不会操作X0寄存器，该寄存器值恒为0
        r_regs[rd_waddr_i] <= rd_wdata_i;                           //写操作寄存器
    end
end
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// DATA_MEM(数据存储器)
//---------------------------------------------------------------------
module data_memory (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from MEM
    input  wire                         dm_wr_en_i                 ,
    input  wire        [  31:0]         dm_addr_i                  ,
    input  wire        [  31:0]         dm_wdata_i                 ,

    input  wire                         dm_rd_en_i                 ,
    output wire        [  31:0]         dm_rdata_o                 ,
    //to top
    input  wire                         rd_en_i                    ,
    input  wire        [  31:0]         rd_addr_i                  ,
    output reg         [  31:0]         rd_data_o                   
);

double_port_ram # (
    .ADDR_WIDTH                        (32                        ),
    .DATA_WIDTH                        (32                        ),
    .RAM_DEPTH                         (4096                      ) 
  )
  double_port_ram_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    
    .wr_en_i                           (dm_wr_en_i                ),
    .wr_addr_i                         (dm_addr_i                 ),
    .wr_data_i                         (dm_wdata_i                ),

    .rd_en_i                           (dm_rd_en_i                ),
    .rd_addr_i                         (dm_addr_i                 ),
    .rd_data_o                         (dm_rdata_o                ) 
  );
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// double_port_ram(双口RAM)
//---------------------------------------------------------------------
module double_port_ram #(
    parameter                           ADDR_WIDTH = 32            ,
    parameter                           DATA_WIDTH = 32            ,
    parameter                           RAM_DEPTH = 4096            
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //write
    input  wire                         wr_en_i                    ,
    input  wire        [ADDR_WIDTH-1:0] wr_addr_i                  ,
    input  wire        [DATA_WIDTH-1:0] wr_data_i                  ,
    //read
    input  wire                         rd_en_i                    ,
    input  wire        [ADDR_WIDTH-1:0] rd_addr_i                  ,
    output reg         [DATA_WIDTH-1:0] rd_data_o                   
);
reg                    [DATA_WIDTH-1:0] ram[0:RAM_DEPTH-1]         ;

always@(posedge sys_clk_i)begin
    if (rst_n_i && wr_en_i)
        ram[wr_addr_i] <= wr_addr_i;
end

always@(posedge sys_clk_i)begin
    if (rst_n_i && rd_en_i)
        rd_data_o <= ram[rd_addr_i];
end
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 同步复位的D触发器(Delay_flip_flop or Data_flip_flop)
//---------------------------------------------------------------------
module dff_sync #(
    parameter                           DATA_WIDTH = 32             
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    input  wire        [DATA_WIDTH-1:0] reset_data_i               ,
    input  wire        [DATA_WIDTH-1:0] data_i                     ,
    output reg         [DATA_WIDTH-1:0] data_o                      
);
always @(posedge sys_clk_i)begin
    if(!rst_n_i)
        data_o <= reset_data_i;
    else
        data_o <= data_i;
end
endmodule