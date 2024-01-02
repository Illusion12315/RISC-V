`timescale 1ns/1ps
module RV32I_sim();
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
wire                   [  31:0]         x26                        ;
wire                   [  31:0]         x27                        ;
wire                   [  31:0]         x3                         ;

assign x3 = RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[3];
assign x26 = RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[26];
assign x27 = RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[27];

initial begin
    sys_clk_i = 0;
    rst_n_i = 0;
    #23
    rst_n_i = 1;
end

integer n;

initial begin
    // $readmemb("E:/risc_v_project/rtl/module/123.bin",RV32I_core_wrapper_inst.RV32I_core_i.instruction_fetch_0.inst.instruction_memory_inst.rom_memo);
    $readmemh("E:/risc_v_project/tb/inst_txt/rv32ui-p-addi.txt",RV32I_core_wrapper_inst.RV32I_core_i.instruction_fetch_0.inst.instruction_memory_inst.rom_memo);
end

initial begin
    // while (1) begin
    //     @(posedge sys_clk_i)
    //     $display("x27 register value is %d",RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[27]);
    //     $display("x28 register value is %d",RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[28]);
    //     $display("x29 register value is %d",RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[29]);
    //     $display("---------------------------------");
    // end
    wait(x26);
    #200;
    if (x27 == 1) begin
        $display("PASS!!!!!!!!!");
    end
    else begin
        $display("FAIL!!!!!!!!!");
        $display("fail testnum = %d",x3);
        for (n = 0; n<=31; n=n+1) begin
            $display("x%2d register value is %d",n,RV32I_core_wrapper_inst.RV32I_core_i.instruction_decode_0.inst.registers_inst.r_regs[n]);
        end
    end
end

RV32I_core_wrapper RV32I_core_wrapper_inst(
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ) 
    );

always #5 sys_clk_i = ~sys_clk_i;
endmodule