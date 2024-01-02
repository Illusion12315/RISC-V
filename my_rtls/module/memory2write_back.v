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