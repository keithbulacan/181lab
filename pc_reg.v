module pc_reg(
    input clock,
    input reset,
    input [31:0] pc_next_in,
    output reg [31:0] pc_out
);

    always @(posedge clock) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= pc_next_in;
    end

endmodule