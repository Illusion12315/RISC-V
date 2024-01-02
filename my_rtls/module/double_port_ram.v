// ********************************************************************************** // 
//---------------------------------------------------------------------
// double_port_ram(Ë«¿ÚRAM)
//---------------------------------------------------------------------
module double_port_ram #(
    parameter                           ADDR_WIDTH = 32            ,
    parameter                           DATA_WIDTH = 32            ,
    parameter                           RAM_DEPTH = 4096            
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //write
    input  wire                         wr_en_i                    ,
    input  wire        [ADDR_WIDTH-1:0] wr_addr_i                  ,
    input  wire        [DATA_WIDTH-1:0] wr_data_i                  ,
    //read
    input  wire                         rd_en_i                    ,
    input  wire        [ADDR_WIDTH-1:0] rd_addr_i                  ,
    output reg         [DATA_WIDTH-1:0] rd_data_o                   
);
reg                    [DATA_WIDTH-1:0] ram[0:RAM_DEPTH-1]         ;

integer i;

initial begin
    for (i = 0; i<RAM_DEPTH; i=i+1) begin
        ram[i] = 32'hffff_ffff;
    end
    rd_data_o = 32'hffff_ffff;
end

always@(posedge sys_clk_i)begin
    if (rst_n_i && wr_en_i)
        ram[wr_addr_i] <= wr_addr_i;
end

always@(posedge sys_clk_i)begin
    if (rst_n_i && rd_en_i)
        rd_data_o <= ram[rd_addr_i];
end
endmodule