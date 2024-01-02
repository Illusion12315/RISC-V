// ********************************************************************************** // 
//---------------------------------------------------------------------
// DATA_MEM(Êý¾Ý´æ´¢Æ÷)
//---------------------------------------------------------------------
module data_memory (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from MEM
    input  wire                         dm_wr_en_i                 ,
    input  wire        [  31:0]         dm_addr_i                  ,
    input  wire        [  31:0]         dm_wdata_i                 ,

    input  wire                         dm_rd_en_i                 ,
    output wire        [  31:0]         dm_rdata_o                 ,
    //to top
    input  wire                         rd_en_i                    ,
    input  wire        [  31:0]         rd_addr_i                  ,
    output reg         [  31:0]         rd_data_o                   
);

double_port_ram # (
    .ADDR_WIDTH                        (32                        ),
    .DATA_WIDTH                        (32                        ),
    .RAM_DEPTH                         (65536                      ) 
  )
  double_port_ram_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    
    .wr_en_i                           (dm_wr_en_i                ),
    .wr_addr_i                         (dm_addr_i                 ),
    .wr_data_i                         (dm_wdata_i                ),

    .rd_en_i                           (dm_rd_en_i                ),
    .rd_addr_i                         (dm_addr_i                 ),
    .rd_data_o                         (dm_rdata_o                ) 
  );
endmodule