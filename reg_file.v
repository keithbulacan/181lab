module reg_file(
    input clock,
    input reset,
    input we_in,                  // Write enable
    input [4:0] raddr1_in,        // Read address 1
    input [4:0] raddr2_in,        // Read address 2
    input [4:0] waddr_in,         // Write address
    input [31:0] wdata_in,        // Write data
    output [31:0] rdata1_out,     // Read data 1
    output [31:0] rdata2_out      // Read data 2
);

    reg [31:0] regs [31:0];       // 32 registers
	 integer i;

    // Asynchronous reads
    assign rdata1_out = (raddr1_in == 5'd0) ? 32'b0 : regs[raddr1_in];
    assign rdata2_out = (raddr2_in == 5'd0) ? 32'b0 : regs[raddr2_in];

    // Synchronous writes
    always @(posedge clock) begin
        if (reset) begin
		  
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (we_in && (waddr_in != 5'd0)) begin
            regs[waddr_in] <= wdata_in;
        end
    end

endmodule