`include "defines.v"
// ********************************************************************************** // 
//---------------------------------------------------------------------
// IF_ID
//---------------------------------------------------------------------
module instruction_fetch2instruction_decode (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from IF
    input  wire        [  31:0]         instruction_addr_i         ,
    input  wire        [  31:0]         instruction_i              ,//from IF
    //to ID
    output wire        [  31:0]         instruction_addr_o         ,
    output wire        [  31:0]         instruction_o               //to ID
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,`INST_NOP,instruction_i,instruction_o);//Delay_flip_flop default to INST_NOP
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);//Data_flip_flop
endmodule