`timescale 1ns / 1ps

module control_unit(
    input [5:0] opcode,
    input [5:0] funct,
    output reg reg_dst,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg [5:0] alu_func,
    output reg [1:0] data_size // 2'b11 for Words
);

    // MIPS Opcodes
    localparam OP_R_TYPE = 6'b000000;
    localparam OP_LW     = 6'b100011;
    localparam OP_SW     = 6'b101011;
    localparam OP_ADDI   = 6'b001000;

    // ALU Function Codes (Matches your alu.v mapping)
    localparam ALU_ADD = 6'b100000;
    localparam ALU_SUB = 6'b100010;
    localparam ALU_AND = 6'b100100;
    localparam ALU_OR  = 6'b100101;
    localparam ALU_XOR = 6'b100110;
    localparam ALU_NOR = 6'b100111;

    always @(*) begin
        // Defaults (prevent latches)
        reg_dst    = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_func   = ALU_ADD;
        data_size  = 2'b11; // Default to Word size

        case (opcode)
            OP_R_TYPE: begin
                reg_dst    = 1'b1; // Write to rd
                alu_src    = 1'b0; // Use Register B
                mem_to_reg = 1'b0; // Use ALU result
                reg_write  = 1'b1; // Enable write
                
                // Decode Function Code for R-Type
                case (funct)
                    6'b100000: alu_func = ALU_ADD; // ADD
                    6'b100010: alu_func = ALU_SUB; // SUB
                    6'b100100: alu_func = ALU_AND; // AND
                    6'b100101: alu_func = ALU_OR;  // OR
                    6'b100110: alu_func = ALU_XOR; // XOR
                    6'b100111: alu_func = ALU_NOR; // NOR
                    default:   alu_func = ALU_ADD;
                endcase
            end

            OP_ADDI: begin
                reg_dst    = 1'b0; // Write to rt
                alu_src    = 1'b1; // Use Immediate
                mem_to_reg = 1'b0; // Use ALU result
                reg_write  = 1'b1;
                alu_func   = ALU_ADD;
            end

            OP_LW: begin
                reg_dst    = 1'b0; // Write to rt
                alu_src    = 1'b1; // Calculate Address (Reg + Imm)
                mem_to_reg = 1'b1; // Use Memory Result
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_func   = ALU_ADD;
            end

            OP_SW: begin
                // reg_dst X (don't care)
                alu_src    = 1'b1; // Calculate Address (Reg + Imm)
                // mem_to_reg X
                // reg_write 0
                mem_write  = 1'b1;
                alu_func   = ALU_ADD;
            end
            
            // Add default case to handle unknown opcodes gracefully
            default: begin
                reg_write = 1'b0;
            end
        endcase
    end

endmodule