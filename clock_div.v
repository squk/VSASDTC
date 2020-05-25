module clock_div #(
	parameter NTH_CLOCK = 2
) (
	input rst, in,
	output reg out
);

reg [31:0] count;

always @ (posedge in) begin
	if (rst) begin
		count <= 0;
	end
	if (count == NTH_CLOCK - 1) begin
		count <= 0;
		out <= ~out;
	end
	else begin
		count <= count + 1;
	end
end 

endmodule
