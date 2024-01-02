`include "defines.v"
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
    output reg         [   2:0]         JJLA_ctrl_o                ,

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
    output reg                          MemtoReg_o                  
);
//

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
assign rs1_o  = instruction_r[19:15];                               //源寄存器1
assign rs2_o  = instruction_r[24:20];                               //源寄存器2
assign func7  = instruction_r[31:25];
assign imm_i  = instruction_r[31:20];

assign imm_s = {instruction_r[31:25],instruction_r[11:7]};

assign imm_u  = instruction_r[31:12];

assign instruction_addr_o = instruction_addr_i;
assign ALU_ctrl_o = {instruction_r[30],instruction_r[14:12]};

assign rs1_raddr_r = rs1_o;                                         //从寄存器堆取出地址为rs1的数
assign rs1_rdata_o = rs1_rdata_r;
assign rs2_raddr_r = rs2_o;                                         //从寄存器堆取出地址为rs2的数
assign rs2_rdata_o = rs2_rdata_r;

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
        `INST_JAL: begin
            imm_gen_o = {{12{imm_u[19]}},imm_u[19],imm_u[7:0],imm_u[8],imm_u[18:9]};
            //EX ctrl
            ALUSrc_o   = 1'b0;                                      //choose alu_data2 from imm or rs2
            ALUOp_o    = 2'b00;                                     //加法
            //MEM ctrl
            Branch_o   = 1'd1;                                      //choose pc from immx2 or +4
            MemRead_r  = 1'd0;
            MemWrite_r = 1'd0;
            //WB ctrl
            RegWrite_o = 1'd1;
            MemtoReg_o = 1'd0;
        end
        //command : INST_JALR
        `INST_JALR: begin
            imm_gen_o = {{20{imm_i[11]}},imm_i};
            //EX ctrl
            ALUSrc_o   = 1'b0;                                      //choose alu_data2 from imm or rs2
            ALUOp_o    = 2'b00;                                     //加法
            //MEM ctrl
            Branch_o   = 1'd1;                                      //choose pc from immx2 or +4
            MemRead_r  = 1'd0;
            MemWrite_r = 1'd0;
            //WB ctrl
            RegWrite_o = 1'd1;
            MemtoReg_o = 1'd0;
        end
        //command : INST_LUI
        `INST_LUI: begin
            imm_gen_o = {{12{imm_u[19]}},imm_u} << 12;
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
        //command : INST_AUIPC
        `INST_AUIPC: begin
            imm_gen_o = {{{12{imm_u[19]}},imm_u} << 12};
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
        `INST_JAL: JJLA_ctrl_o = 3'd1;
        `INST_JALR: JJLA_ctrl_o = 3'd2;
        `INST_LUI: JJLA_ctrl_o = 3'd3;
        `INST_AUIPC: JJLA_ctrl_o = 3'd4;
        default: JJLA_ctrl_o = 3'd0;
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