`include "defines.v"
// ********************************************************************************** // 
//---------------------------------------------------------------------
// IF(ȡָ)
//---------------------------------------------------------------------
module instruction_fetch (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    
    input  wire                         PCSrc_i                    ,
    input  wire        [  31:0]         instruction_addr_i         ,
    // from hazard_detection_unit
    input  wire                         stall_en_i                 ,
    // to ID
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         instruction_o               
);
reg                    [  31:0]         pc_r                       ;
wire                   [  31:0]         pc_add                     ;
wire                   [  31:0]         pc                         ;
wire                   [  31:0]         instruction_r              ;

assign instruction_addr_o = pc_r;
assign instruction_o = (PCSrc_i || stall_en_i)? `INST_NOP:instruction_r;
assign pc_add = pc_r + 32'd4;

assign pc = (PCSrc_i)? instruction_addr_i:pc_add;

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        pc_r <= 32'd0;
    else if (stall_en_i)
        pc_r <= pc_r;
    else
        pc_r <= pc;
end

instruction_memory instruction_memory_inst(
    // from pc
    .instruction_addr_i                (pc_r                      ),
    // to ID
    .instruction_o                     (instruction_r             ) 
);
endmodule