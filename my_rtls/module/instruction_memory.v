// ********************************************************************************** // 
//---------------------------------------------------------------------
// INST_MEM(Ö¸Áî´æ´¢Æ÷)
//---------------------------------------------------------------------
module instruction_memory (
    input  wire        [  31:0]         instruction_addr_i         ,
    output wire        [  31:0]         instruction_o               
);
reg                    [  31:0]         rom_memo[0:4095]           ;//4096 32bits
assign instruction_o = rom_memo[instruction_addr_i>>2];
// integer n;

// initial begin
//     $readmemb("E:/risc_v_project/rtl/module/123.bin",rom_memo);
//     for (n = 0;n<=4095; n=n+1) begin
//         $display("%b",rom_memo[n]);
//     end
// end

endmodule