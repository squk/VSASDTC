module ram_infer #(
    parameter RAM_DATA_WIDTH = 15,             // width of the data
    parameter RAM_ADDR_WIDTH = 16              // number of address bits
)
(
	input [RAM_DATA_WIDTH-1:0] data,
	input [RAM_ADDR_WIDTH-1:0] read_addr, write_addr,
	input we, clk,
	output reg [RAM_DATA_WIDTH-1:0] q
);

	localparam RAM_DATA_DEPTH = 2**RAM_ADDR_WIDTH;  // depth of the ram, this is tied to the number of address bits

	// Declare the RAM variable
	reg [RAM_DATA_WIDTH-1:0] ram[RAM_DATA_DEPTH-1:0];

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;

		// Read (if read_addr == write_addr, return OLD data).	To return
		// NEW data, use = (blocking write) rather than <= (non-blocking write)
		// in the write assignment.	 NOTE: NEW data may require extra bypass
		// logic around the RAM.
		q <= ram[read_addr];
	end

endmodule
