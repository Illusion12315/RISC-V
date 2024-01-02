`include "defines.v"
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
    input  wire        [   2:0]         JJLA_ctrl_i                ,

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
    output reg         [  31:0]         instruction_addr_o         ,
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
wire                   [  31:0]         instruction_addr           ;
    //WB ctrl
assign RegWrite_o = (PCSrc_i)? 1'b0:RegWrite_i;
assign MemtoReg_o = (PCSrc_i)? 1'b0:MemtoReg_i;
    //MEM ctrl
assign Branch_o = (PCSrc_i)? 1'b0:Branch_i;
assign MemRead_o = (PCSrc_i)? 1'b0:MemRead_i;
assign MemWrite_o = (PCSrc_i)? 1'b0:MemWrite_i;

assign alu_data2 = (ALUSrc_i)? imm_gen_i : alu_data2_r;
assign alu_data2_shift1 = imm_gen_i << 1;                           //地址偏移x2

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
    case (JJLA_ctrl_i)
        3'd1: alu_result_o = instruction_addr_i + 32'd4;
        3'd2: alu_result_o = instruction_addr_i + 32'd4;
        3'd3: alu_result_o = imm_gen_i;
        3'd4: alu_result_o = instruction_addr_i + imm_gen_i;
        default: begin
            case (ALUOp_i)
                2'b00: alu_result_o = alu_data1 + alu_data2;        //load or store
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
                        {3'b001}: alu_result_o = alu_data1 << alu_data2;//INST_SLL or 
                        {3'b101}: begin
                            case (ALU_ctrl_i[3])
                                1'b1: alu_result_o = $signed(alu_data1) >>> alu_data2[4:0];//>>>表示,对于有符号数,用符号位填充
                                default: alu_result_o = alu_data1 >> alu_data2[4:0];//右移,补0
                            endcase
                        end
                        default: alu_result_o = 32'd0;
                    endcase
                end
                2'b11: alu_result_o = instruction_addr_i + 32'd4;   //jar
                default: alu_result_o = 32'd0;
            endcase
        end
    endcase
end

always@(*)begin
    case (JJLA_ctrl_i)
        3'd1: condition_en_o = 1'b1;
        3'd2: condition_en_o = 1'b1;
        default: begin
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
    endcase
end

assign instruction_addr = alu_data1 + imm_gen_i;

always@(*)begin
    case (JJLA_ctrl_i)
        3'd1: instruction_addr_o = instruction_addr_i + alu_data2_shift1;
        3'd2: instruction_addr_o = {instruction_addr[31:1],1'b0};
        default: instruction_addr_o = instruction_addr_i + alu_data2_shift1;
    endcase
end
endmodule