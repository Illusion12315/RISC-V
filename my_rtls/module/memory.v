// ********************************************************************************** // 
//---------------------------------------------------------------------
// MEM(Êý¾Ý´æ´¢Æ÷·ÃÎÊ)
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