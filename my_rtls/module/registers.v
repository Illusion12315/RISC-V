// ********************************************************************************** // 
//---------------------------------------------------------------------
// REGS(寄存器堆)
//---------------------------------------------------------------------
module registers (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    //from id
    input  wire        [   4:0]         rs1_raddr_i                ,
    input  wire        [   4:0]         rs2_raddr_i                ,
	//to id
    output reg         [  31:0]         rs1_rdata_o                ,
    output reg         [  31:0]         rs2_rdata_o                ,
	//from ex
    input  wire        [   4:0]         rd_waddr_i                 ,
    input  wire        [  31:0]         rd_wdata_i                 ,
    input  wire                         rd_wr_en_i                  
);
//一共有x0~x31一共32个寄存器,加上一个rdata
reg                    [  31:0]         r_regs[0:31]               ;//32 32bits

integer i;
//rs1
always @(*)begin
    if(rst_n_i == 1'b0)
        rs1_rdata_o <= 32'b0;
    else if(rs1_raddr_i == 5'b0)
        rs1_rdata_o <= 32'b0;
    else if(rd_wr_en_i && rs1_raddr_i == rd_waddr_i)                //指令冲突
        rs1_rdata_o <= rd_wdata_i;
    else
        rs1_rdata_o <= r_regs[rs1_raddr_i];                         //一直给rs1赋值
end
//rs2
always @(*)begin
    if(rst_n_i == 1'b0)
        rs2_rdata_o <= 32'b0;
    else if(rs2_raddr_i == 5'b0)                                    //置零
        rs2_rdata_o <= 32'b0;
    else if(rd_wr_en_i && rs2_raddr_i == rd_waddr_i)                //指令冲突
        rs2_rdata_o <= rd_wdata_i;
    else
        rs2_rdata_o <= r_regs[rs2_raddr_i];                         //一直给r2赋值
end
//该部分打拍相当于回写之后的目标自己的寄存器
always @(posedge sys_clk_i)begin
    if(!rst_n_i) begin
        for(i=0;i<32;i=i+1)begin
            r_regs[i] <= 32'b0;
        end
    end
    else if(rd_wr_en_i && rd_waddr_i != 5'b0)begin                  //相当于永远不会操作X0寄存器，该寄存器值恒为0
        r_regs[rd_waddr_i] <= rd_wdata_i;                           //写操作寄存器
    end
end
endmodule