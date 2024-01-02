`timescale 1ns/1ps
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 同步复位的D触发器(Delay_flip_flop or Data_flip_flop)
//---------------------------------------------------------------------
module dff_sync #(
    parameter                           DATA_WIDTH = 32             
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    input  wire        [DATA_WIDTH-1:0] reset_data_i               ,
    input  wire        [DATA_WIDTH-1:0] data_i                     ,
    output reg         [DATA_WIDTH-1:0] data_o                      
);
always @(posedge sys_clk_i)begin
    if(!rst_n_i)
        data_o <= reset_data_i;
    else
        data_o <= data_i;
end
endmodule