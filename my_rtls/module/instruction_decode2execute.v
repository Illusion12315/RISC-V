`include "defines.v"
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
    input  wire        [   2:0]         JJLA_ctrl_i                ,

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
    output wire        [   2:0]         JJLA_ctrl_o                ,

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

dff_sync #(3) dff16(sys_clk_i,rst_n_i,3'd0,JJLA_ctrl_i,JJLA_ctrl_o);
endmodule