`timescale 1ns / 1ps

module control_tb;

    // --- Test Signals ---
    reg [31:0] sim_inst;  // Simulation Instruction Register
    
    // --- DUT Outputs ---
    wire w_reg_dst, w_alu_src, w_mem_to_reg, w_reg_write;
    wire w_mem_read, w_mem_write;
    wire [5:0] w_alu_func;
    wire [1:0] w_data_size;

    // --- Opcode Constants (Makes code cleaner) ---
    localparam OP_R     = 6'b000000;
    localparam OP_ADDI  = 6'b001000;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;

    // --- Funct Constants ---
    localparam F_ADD = 6'b100000;
    localparam F_SUB = 6'b100010;
    localparam F_AND = 6'b100100;
    localparam F_OR  = 6'b100101;
    localparam F_XOR = 6'b100110;
    localparam F_NOR = 6'b100111;

    // --- Instantiate Device Under Test (DUT) ---
    control_unit DUT (
        .opcode     (sim_inst[31:26]),
        .funct      (sim_inst[5:0]),
        .reg_dst    (w_reg_dst),
        .alu_src    (w_alu_src),
        .mem_to_reg (w_mem_to_reg),
        .reg_write  (w_reg_write),
        .mem_read   (w_mem_read),
        .mem_write  (w_mem_write),
        .alu_func   (w_alu_func),
        .data_size  (w_data_size)
    );

    // --- Main Test Procedure ---
    initial begin
        $display("========================================");
        $display("    Starting Control Unit Verification  ");
        $display("========================================");

        // 1. Check ADD (R-Type)
        // Construction: {Opcode, rs, rt, rd, shamt, funct}
        sim_inst = {OP_R, 5'd0, 5'd0, 5'd0, 5'd0, F_ADD}; 
        #10;
        $display("[TEST] R-Type ADD:");
        verify_signal("RegDst",    w_reg_dst,   1'b1);
        verify_signal("RegWrite",  w_reg_write, 1'b1);
        verify_vector("ALU Func",  w_alu_func,  F_ADD);

        // 2. Check LW
        sim_inst = {OP_LW, 26'd0}; // Filler bits don't matter for control
        #10;
        $display("\n[TEST] Load Word (LW):");
        verify_signal("ALUSrc",    w_alu_src,    1'b1);
        verify_signal("MemToReg",  w_mem_to_reg, 1'b1);
        verify_signal("MemRead",   w_mem_read,   1'b1);
        verify_signal("RegWrite",  w_reg_write,  1'b1);

        // 3. Check SW
        sim_inst = {OP_SW, 26'd0};
        #10;
        $display("\n[TEST] Store Word (SW):");
        verify_signal("ALUSrc",    w_alu_src,    1'b1);
        verify_signal("MemWrite",  w_mem_write,  1'b1);
        verify_signal("RegWrite",  w_reg_write,  1'b0);

        // 4. Check ADDI
        sim_inst = {OP_ADDI, 26'd0};
        #10;
        $display("\n[TEST] ADDI:");
        verify_signal("RegDst",    w_reg_dst,    1'b0);
        verify_signal("ALUSrc",    w_alu_src,    1'b1);
        verify_signal("RegWrite",  w_reg_write,  1'b1);

        // 5. Check Other ALU Operations
        $display("\n[TEST] ALU Functions Checks:");
        
        // SUB
        sim_inst = {OP_R, 20'd0, F_SUB}; #10;
        verify_vector("SUB Check", w_alu_func, F_SUB);

        // AND
        sim_inst = {OP_R, 20'd0, F_AND}; #10;
        verify_vector("AND Check", w_alu_func, F_AND);

        // OR
        sim_inst = {OP_R, 20'd0, F_OR};  #10;
        verify_vector("OR  Check", w_alu_func, F_OR);

        // XOR
        sim_inst = {OP_R, 20'd0, F_XOR}; #10;
        verify_vector("XOR Check", w_alu_func, F_XOR);

        // NOR
        sim_inst = {OP_R, 20'd0, F_NOR}; #10;
        verify_vector("NOR Check", w_alu_func, F_NOR);

        $display("========================================");
        $display("       All Unit Tests Completed.        ");
        $display("========================================");
        $finish;
    end

    // --- Helper Tasks for clean checking ---
    
    // Task to verify single-bit signals
    task verify_signal;
        input [8*10:1] name; // String input
        input actual;
        input expected;
        begin
            if (actual !== expected) 
                $display("   [FAIL] %s: Expected %b, Got %b", name, expected, actual);
            else
                $display("   [PASS] %s", name);
        end
    endtask

    // Task to verify vector signals (like ALUOp)
    task verify_vector;
        input [8*10:1] name;
        input [5:0] actual;
        input [5:0] expected;
        begin
            if (actual !== expected) 
                $display("   [FAIL] %s: Expected %h, Got %h", name, expected, actual);
            else
                $display("   [PASS] %s", name);
        end
    endtask

endmodule