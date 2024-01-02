// ********************************************************************************** // 
//---------------------------------------------------------------------
// forwarding_unit(Ç°µÝ)
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