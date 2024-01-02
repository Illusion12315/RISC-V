`include "defines.v"
// ********************************************************************************** // 
//---------------------------------------------------------------------
// program_counter(指令计数器)
//---------------------------------------------------------------------
module pc_reg (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    output wire        [  31:0]         pc_o                        //程序计数器
);

reg                    [  31:0]         pc_r                       ;//program_counter

assign pc_o = pc_r ;

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin                                             //同步复位
        pc_r <= 32'd0 ;
    end
    else begin
        pc_r <= pc_r + 32'd4 ;                                      //32位指令，四个字节
    end
end
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// instruction_fetch(取指)
//---------------------------------------------------------------------
module ifetch (
    //from pc
    input  wire        [  31:0]         pc_addr_i                  ,//pc_addr = pc_o
    //to rom
    output wire        [  31:0]         if2rom_addr_o              ,//instruction_fetch to rom
    //form Instruction memory
    input  wire        [  31:0]         rom_instruction_i           ,
    //to if_id
    output wire        [  31:0]         instruction_addr_o          ,
    //
    output wire        [  31:0]         instruction_o                //取到的指令
);
assign if2rom_addr_o = pc_addr_i;
assign instruction_addr_o = pc_addr_i;
assign instruction_o = rom_instruction_i;
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// rom(instruction memory)
//---------------------------------------------------------------------
module rom (
    input  wire        [  31:0]         instruction_addr_i          ,
    output wire        [  31:0]         instruction_o                
);
reg                    [  31:0]         rom_memo[0:4095]           ;//4096 32bits
assign instruction_o = rom_memo[instruction_addr_i>>2];
endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// instruction_fetch_2_instruction_decode(打拍)
//---------------------------------------------------------------------
module if_id (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    input  wire        [  31:0]         instruction_addr_i          ,
    input  wire        [  31:0]         instruction_i               ,//from rom
    output wire        [  31:0]         instruction_addr_o          ,
    output wire                         instruction_o                //to decode
);
dff_sync #(32) dff1(sys_clk_i,rst_n_i,`INST_NOP,instruction_i,instruction_o);//Delay_flip_flop default to INST_NOP_OP
dff_sync #(32) dff2(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);//Data_flip_flop
endmodule
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
// ********************************************************************************** // 
//---------------------------------------------------------------------
// instruction_decode(译码)
//---------------------------------------------------------------------
module id (
	//from if_id
    input  wire        [  31:0]         instruction_i              ,
    input  wire        [  31:0]         instruction_addr_i         ,
	// to r_regs 
    output reg         [   4:0]         rs1_addr_o                 ,//register source1 address
    output reg         [   4:0]         rs2_addr_o                 ,//register source2 address
	// from r_regs
    input  wire        [  31:0]         rs1_data_i                 ,//register source1 data
    input  wire        [  31:0]         rs2_data_i                 ,//register source2 data
	//to id_ex
    output reg         [  31:0]         instruction_o              ,
    output reg         [  31:0]         instruction_addr_o         ,
    output reg         [  31:0]         op1_o                      ,
    output reg         [  31:0]         op2_o                      ,
    output reg         [   4:0]         rd_waddr_o                 ,//register destination
    output reg                          rd_wr_en_o                  //register destination
);
wire                   [   6:0]         opcode                     ;
wire                   [   4:0]         rd                         ;//register destination
wire                   [   2:0]         func3                      ;//function
wire                   [   4:0]         rs1                        ;//register source1
wire                   [   4:0]         rs2                        ;//register source2
wire                   [   6:0]         func7                      ;//function
wire                   [  11:0]         imm_i                      ;//immediate data i 类
wire                   [   4:0]         imm_s1                     ;//immediate data s or b
wire                   [   6:0]         imm_s2                     ;//immediate data s or b
wire                   [  19:0]         imm_u                      ;//immediate data u

assign opcode = instruction_i[6:0];
assign rd     = instruction_i[11:7];
assign func3  = instruction_i[14:12];
assign rs1    = instruction_i[19:15];
assign rs2    = instruction_i[24:20];
assign func7  = instruction_i[31:25];
assign imm_i  = instruction_i[31:20];

assign imm_s1 = instruction_i[11:7];
assign imm_s2 = instruction_i[31:25];

assign imm_u  = instruction_i[31:12];

always@(*)begin
    instruction_o      <= instruction_i;
    instruction_addr_o <= instruction_addr_i;                         //
    case (opcode)
        //command : INST_TYPE_I
        `INST_TYPE_I: begin                                         //I型指令
            case (func3)
                `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI,`INST_SLLI,`INST_SRI: begin
                    rs1_addr_o <= rs1;                              //从寄存器堆取出地址为rs1的数
                    rs2_addr_o <= 5'b0;                             //不需要从寄存器堆取出地址位rs2的数，因为数为产生的立即数
                    op1_o <= rs1_data_i;                            //从寄存器堆取出的地址为rs1的数
                    op2_o <= {{20{imm_i[11]}},imm_i};               //为需要产生的立即数，[11:0]12位,且需要进行符号位扩展
                    rd_waddr_o <= rd;                               //指向目的寄存器堆
                    rd_wr_en_o <= 1'b1;
                end
                // `INST_SLTI: begin
                //     rs1_addr_o <= rs1;                              //从寄存器堆取出地址为rs1的数
                //     rs2_addr_o <= 5'b0;                             //不需要从寄存器堆取出地址位rs2的数，因为数为产生的立即数
                //     op1_o <= rs1_data_i;                            //从寄存器堆取出的地址为rs1的数
                //     op2_o <= {{20{imm_i[11]}},imm_i};               //为需要产生的立即数，[11:0]12位
                //     rd_waddr_o <= rd;                               //指向目的寄存器堆
                //     rd_wr_en_o <= 1'b1;
                // end
                // `INST_SLTIU: begin
                    
                // end
                // `INST_XORI: begin
                    
                // end
                // `INST_ORI: begin
                    
                // end
                // `INST_ANDI: begin
                    
                // end
                // `INST_SLLI: begin
                    
                // end
                // `INST_SRI: begin
                    
                // end
                default: begin
                    rs1_addr_o <= 5'd0;
                    rs2_addr_o <= 5'd0;
                    op1_o <= 32'd0;
                    op2_o <= 32'd0;
                    rd_waddr_o <= 5'd0;
                    rd_wr_en_o <= 1'd0;
                end
            endcase
        end
        //command : INST_TYPE_R_M
        `INST_TYPE_R_M: begin                                        //R型指令
            case (func3)
                `INST_ADD_SUB: begin
                    rs1_addr_o <= rs1;
                    rs2_addr_o <= rs2;
                    op1_o <= rs1_data_i;
                    op2_o <= rs2_data_i;
                    rd_waddr_o <= rd;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_SLL: begin
                    
                end
                `INST_SLT: begin
                    
                end
                `INST_SLTU: begin
                    
                end
                `INST_XOR: begin
                    
                end
                `INST_SR: begin
                    
                end
                `INST_OR: begin
                    
                end
                `INST_AND: begin
                    
                end
                default: begin
                    rs1_addr_o <= 5'd0;
                    rs2_addr_o <= 5'd0;
                    op1_o <= 32'd0;
                    op2_o <= 32'd0;
                    rd_waddr_o <= 5'd0;
                    rd_wr_en_o <= 1'd0;
                end
            endcase
        end
        //command : INST_TYPE_S
        `INST_TYPE_S: begin
            case (func3)
                `INST_SB: begin
                    
                end
                `INST_SH: begin
                    
                end
                `INST_SW: begin
                    
                end
                default: begin
                    
                end
            endcase
        end
        //command : INST_TYPE_B(SB型指令)
        `INST_TYPE_B: begin
            case (func3)
                `INST_BEQ: begin
                    
                end
                `INST_BNE: begin
                    
                end
                `INST_BLT: begin
                    
                end
                `INST_BGE: begin
                    
                end
                `INST_BLTU: begin
                    
                end
                `INST_BGEU: begin
                    
                end
                default: begin
                    rs1_addr_o <= 5'd0;
                    rs2_addr_o <= 5'd0;
                    op1_o <= 32'd0;
                    op2_o <= 32'd0;
                    rd_waddr_o <= 5'd0;
                    rd_wr_en_o <= 1'd0;
                end
            endcase
        end
        //command : INST_LUI(U型指令)
        `INST_LUI: begin

        end
        //commadn : INST_JAL(UJ型指令)
        `INST_JAL: begin
            
        end
        default:begin
            rs1_addr_o <= 5'd0;
            rs2_addr_o <= 5'd0;
            op1_o <= 32'd0;
            op2_o <= 32'd0;
            rd_waddr_o <= 5'd0;
            rd_wr_en_o <= 1'd0;
        end
    endcase
end

endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// regs(寄存器堆)
//---------------------------------------------------------------------
module r_regs (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
	//from id
    input  wire        [   4:0]         r1_raddr_i                 ,
    input  wire        [   4:0]         r2_raddr_i                 ,
	
	//to id
    output reg         [  31:0]         r1_rdata_o                 ,
    output reg         [  31:0]         r2_rdata_o                 ,
	
	//from ex
    input  wire        [   4:0]         r_waddr_i                  ,
    input  wire        [  31:0]         r_wdata_i                  ,
    input  wire                         r_wr_en_i                   
);
reg                    [  31:0]         r_regs[0:31]               ;//32 32bits

integer i;

always @(*)begin
    if(rst_n_i == 1'b0)
        r1_rdata_o <= 32'b0;
    else if(r1_raddr_i == 5'b0)
        r1_rdata_o <= 32'b0;
    else if(r_wr_en_i && r1_raddr_i == r_waddr_i)                   //指令冲突
        r1_rdata_o <= r_wdata_i;
    else
        r1_rdata_o <= r_regs[r1_raddr_i];                           //一直给r1赋值
end

always @(*)begin
    if(rst_n_i == 1'b0)
        r2_rdata_o <= 32'b0;
    else if(r2_raddr_i == 5'b0)                                     //置零
        r2_rdata_o <= 32'b0;
    else if(r_wr_en_i && r2_raddr_i == r_waddr_i)                   //指令冲突
        r2_rdata_o <= r_wdata_i;
    else
        r2_rdata_o <= r_regs[r2_raddr_i];                           //一直给r2赋值
end

always @(posedge sys_clk_i)begin
    if(rst_n_i == 1'b0) begin
        for(i=0;i<31;i=i+1)begin
            r_regs[i] <= 32'b0;
        end
    end
    else if(r_wr_en_i && r_waddr_i != 5'b0)begin                    //相当于永远不会操作X0寄存器，该寄存器值恒为0
        r_regs[r_waddr_i] <= r_wdata_i;                             //写操作寄存器
    end
end

endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// id_ex(译码到执行的打拍)
//---------------------------------------------------------------------
module id_ex (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
	//from id
    input  wire        [  31:0]         instruction_i               ,
    input  wire        [  31:0]         instruction_addr_i          ,
    input  wire        [  31:0]         op1_i                      ,
    input  wire        [  31:0]         op2_i                      ,
    input  wire        [   4:0]         rd_waddr_i                 ,
    input  wire                         rd_wr_en_i                 ,
	//to ex
    output wire        [  31:0]         instruction_o               ,
    output wire        [  31:0]         instruction_addr_o          ,
    output wire        [  31:0]         op1_o                      ,
    output wire        [  31:0]         op2_o                      ,
    output wire        [   4:0]         rd_waddr_o                 ,
    output wire                         rd_wr_en_o                  
);

dff_sync #(32) dff3(sys_clk_i,rst_n_i,`INST_NOP,instruction_i,instruction_o);

dff_sync #(32) dff4(sys_clk_i,rst_n_i,32'd0,instruction_addr_i,instruction_addr_o);

dff_sync #(32) dff5(sys_clk_i,rst_n_i,32'd0,op1_i,op1_o);

dff_sync #(32) dff6(sys_clk_i,rst_n_i,32'd0,op2_i,op2_o);

dff_sync #(5) dff7(sys_clk_i,rst_n_i,1'd0,rd_waddr_i,rd_waddr_o);

dff_sync #(1) dff8(sys_clk_i,rst_n_i,1'd0,rd_wr_en_i,rd_wr_en_o);

endmodule
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ex
//---------------------------------------------------------------------
module ex(
	//from id_ex
    input  wire        [  31:0]         instruction_i               ,
    input  wire        [  31:0]         instruction_addr_i          ,
    input  wire        [  31:0]         op1_i                      ,//操作数1
    input  wire        [  31:0]         op2_i                      ,//操作数2
    input  wire        [   4:0]         rd_waddr_i                 ,
    input  wire                         rd_wr_en_i                 ,
	//to regs
    output reg         [   4:0]         rd_waddr_o                 ,
    output reg         [  31:0]         rd_wdata_o                 ,
    output reg                          rd_wr_en_o                  
);
wire                   [   6:0]         opcode                     ;
wire                   [   4:0]         rd                         ;
wire                   [   2:0]         func3                      ;
wire                   [   4:0]         rs1                        ;
wire                   [   4:0]         rs2                        ;
wire                   [   6:0]         func7                      ;
wire                   [  11:0]         imm                        ;
wire                   [   4:0]         shamt                      ;

assign opcode = instruction_i[6:0];
assign rd     = instruction_i[11:7];
assign func3  = instruction_i[14:12];
assign rs1    = instruction_i[19:15];
assign rs2    = instruction_i[24:20];
assign func7  = instruction_i[31:25];
assign imm    = instruction_i[31:20];
assign shamt  = instruction_i[24:20];

always @(*)begin
    case(opcode)

        `INST_TYPE_I:begin
            case(func3)
                `INST_ADDI:begin                                    //addi
                    rd_wdata_o <= op1_i + op2_i;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_SLTI:begin
                    rd_wdata_o <= ($signed(op1_i) < $signed(op2_i))? 1'd1:1'd0;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_SLTIU:begin
                    rd_wdata_o <= (op1_i < op2_i)? 1'd1:1'd0;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_XORI:begin
                    rd_wdata_o <= op1_i ^ op2_i;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_ORI:begin
                    rd_wdata_o <= op1_i | op2_i;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_ANDI:begin
                    rd_wdata_o <= op1_i & op2_i;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_SLLI:begin
                    rd_wdata_o <= op1_i << shamt;
                    rd_waddr_o <= rd_waddr_i;
                    rd_wr_en_o <= 1'b1;
                end
                `INST_SRI:begin
                    
                end
                default:begin
                    rd_wdata_o <= 32'b0;
                    rd_waddr_o <= 5'b0;
                    rd_wr_en_o <= 1'b0;
                end
            endcase
        end

        `INST_TYPE_R_M:begin
            case(func3)
                `INST_ADD_SUB:begin
                    if(func7 == 7'b000_0000)begin                   //add
                        rd_wdata_o <= op1_i + op2_i;
                        rd_waddr_o <= rd_waddr_i;
                        rd_wr_en_o <= 1'b1;
                    end
                    else begin
                        rd_wdata_o <= op2_i - op1_i;
                        rd_waddr_o <= rd_waddr_i;
                        rd_wr_en_o <= 1'b1;
                    end
                end
                default:begin
                    rd_wdata_o <= 32'b0;
                    rd_waddr_o <= 5'b0;
                    rd_wr_en_o <= 1'b0;
                end
            endcase
        end

        default:begin
            rd_wdata_o <= 32'b0;
            rd_waddr_o <= 5'b0;
            rd_wr_en_o <= 1'b0;
        end
    endcase
end
endmodule