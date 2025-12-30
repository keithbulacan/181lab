module adder(
    input [31:0] A_in,
    input [31:0] B_in,
    output [31:0] Sum_out
);

    assign Sum_out = A_in + B_in;

endmodule