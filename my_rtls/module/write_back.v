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