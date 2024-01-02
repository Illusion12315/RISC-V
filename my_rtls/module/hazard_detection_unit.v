// ********************************************************************************** // 
//---------------------------------------------------------------------
// hazard_detection_unit(√∞œ’±£ª§)
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