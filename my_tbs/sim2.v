`timescale 1ns/1ps
module RV32I_sim2();
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
wire                   [  31:0]         x26                        ;
wire                   [  31:0]         x27                        ;
wire                   [  31:0]         x3                         ;
reg                    [  79:0]         instruction                ;

assign x3 = RV32I_core_by_cxz_inst.instruction_decode_inst.registers_inst.r_regs[3];
assign x26 = RV32I_core_by_cxz_inst.instruction_decode_inst.registers_inst.r_regs[26];
assign x27 = RV32I_core_by_cxz_inst.instruction_decode_inst.registers_inst.r_regs[27];

integer n;

initial begin
    sys_clk_i = 0;
    //--------------------------------//
    instruction = "add";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-add.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "addi";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-addi.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "and";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-and.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "andi";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-andi.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "auipc";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-auipc.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "beq";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-beq.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "bge";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-bge.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "bgeu";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-bgeu.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "blt";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-blt.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "bltu";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-bltu.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "bne";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-bne.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    // instruction = "fence_i";
    // $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-fence_i.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    // instrustion_test(instruction);

    //--------------------------------//
    instruction = "jal";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-jal.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "jalr";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-jalr.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "lb";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-lb.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "lbu";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-lbu.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "lh";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-lh.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);

    //--------------------------------//
    instruction = "lhu";
    $readmemh("E:/risc_v_project/my_code/my_tbs/inst_txt/rv32ui-p-lhu.txt",RV32I_core_by_cxz_inst.instruction_fetch_inst.instruction_memory_inst.rom_memo);
    instrustion_test(instruction);
    
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// task
//---------------------------------------------------------------------
task instrustion_test;
    input              [  79:0]         instruction                ;
    begin
        rst_n_i = 0;
        #100;
        rst_n_i = 1;
        wait(x26);
        #200;
        if (x27 == 1) begin
            $display("instruction %0s PASS!!!!!!!!!",instruction);
        end
        else begin
            $display("instruction %0s FAIL!!!!!!!!!",instruction);
            $display("fail testnum = %d",x3);
            for (n = 0; n<=31; n=n+1) begin
                $display("x%2d register value is %h",n,RV32I_core_by_cxz_inst.instruction_decode_inst.registers_inst.r_regs[n]);
            end
            $stop;
        end
    end
endtask

RV32I_core_by_cxz RV32I_core_by_cxz_inst(
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ) 
    );

always #5 sys_clk_i = ~sys_clk_i;
endmodule