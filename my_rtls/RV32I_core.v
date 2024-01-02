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

wire                   [   2:0]         JJLA_ctrl_id2dff           ;
wire                   [   2:0]         JJLA_ctrl_dff2ex           ;

wire                   [   1:0]         ForwardA_fu2ex             ;
wire                   [   1:0]         ForwardB_fu2ex             ;
wire                   [   1:0]         ALUOp_id2dff               ;
wire                   [   1:0]         ALUOp_dff2ex               ;

wire                                    condition_en_ex2dff        ;
wire                                    condition_en_dff2mem       ;
wire                                    PCSrc_mem2if               ;
wire                                    stall_en                   ;
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
    .JJLA_ctrl_o                       (JJLA_ctrl_id2dff          ),
    .rs1_o                             (rs1_id2dff                ),
    .rs2_o                             (rs2_id2dff                ),
    .ALUSrc_o                          (ALUSrc_id2dff             ),
    .ALUOp_o                           (ALUOp_id2dff              ),
    .Branch_o                          (Branch_id2dff             ),
    .MemRead_o                         (MemRead_id2dff            ),
    .MemWrite_o                        (MemWrite_id2dff           ),
    .RegWrite_o                        (RegWrite_id2dff           ),
    .MemtoReg_o                        (MemtoReg_id2dff           )
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
    .JJLA_ctrl_i                       (JJLA_ctrl_id2dff          ),
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
    .JJLA_ctrl_o                       (JJLA_ctrl_dff2ex          ),
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
    .JJLA_ctrl_i                       (JJLA_ctrl_dff2ex          ),
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