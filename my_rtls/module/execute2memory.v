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