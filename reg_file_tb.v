`timescale 1ns/1ps

module reg_file_tb();

    reg clock;
    reg reset;
    reg we_in;
    reg [4:0] raddr1_in, raddr2_in, waddr_in;
    reg [31:0] wdata_in;
    wire [31:0] rdata1_out, rdata2_out;

    // Instantiate DUT
    reg_file dut (
        .clock(clock),
        .reset(reset),
        .we_in(we_in),
        .raddr1_in(raddr1_in),
        .raddr2_in(raddr2_in),
        .waddr_in(waddr_in),
        .wdata_in(wdata_in),
        .rdata1_out(rdata1_out),
        .rdata2_out(rdata2_out)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100 MHz
    end

    // Stimulus
    initial begin
        $dumpfile("reg_file_tb.vcd"); // waveform file
        $dumpvars(0, reg_file_tb);

        reset = 1; we_in = 0;
        #10 reset = 0;

        // Write to register 5
        waddr_in = 5; wdata_in = 32'hDEADBEEF; we_in = 1;
        #10 we_in = 0;

        // Read back from register 5
        raddr1_in = 5; raddr2_in = 0; // also read reg0
        #10;

        $display("Reg5 = %h, Reg0 = %h", rdata1_out, rdata2_out);

        // Try writing to register 0
        waddr_in = 0; wdata_in = 32'hFFFFFFFF; we_in = 1;
        #10 we_in = 0;

        // Read register 0 again
        raddr1_in = 0; raddr2_in = 5;
        #10;

        $display("Reg0 after write = %h (should be 0)", rdata1_out);

        $finish;
    end

endmodule