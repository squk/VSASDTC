module test_fb(
	input i_rst,
	input i_clk,
	input i_DCLK,
	input i_LP, i_SPL, i_CLS, i_SPS, i_MOD, i_VCOM,
	input [4:0] i_R, // 5-bit Red
	input [4:0] i_G, // 5-bit Green
	input [4:0] i_B, // 5-bit Blue
	
	output wire o_wrclk,
	output wire o_wre, 
	output reg [15:0] o_wraddr,
	output reg [14:0] o_data,
	output wire [7:0] o_LED
);

localparam WIDTH  = 240;             // complete line (pixels)
localparam HEIGHT = 160;             // complete screen (lines)

assign o_wre = i_clk;
assign o_wrclk = i_clk;


assign o_LED = o_wraddr;

reg [15:0] cnt;
reg [7:0] v_count, h_count;

// In RAM:
// 15'b11111_00000_00000 = RED
// 15'b00000_11111_00000 = GREEN
// 15'b00000_00000_11111 = BLUE

always @ (posedge o_wrclk) begin
	if (i_rst) begin // reset to start of frame
		h_count <= 0;
		v_count <= 0;
	end
	
	if (h_count == WIDTH) begin // end of line
		 h_count <= 0;
		 v_count <= v_count + 1'b1;
	end
	else 
		 h_count <= h_count + 1'b1;

	if (v_count == HEIGHT)  // end of screen
		v_count <= 0;
end

always @ (*) begin
	o_wraddr <= (v_count * 240) + h_count;
	
	if (v_count < HEIGHT/2) begin
		if (v_count == 0)
			o_data <= 15'b00000_11111_00000;
		else if (v_count < HEIGHT/4)
			o_data <= 15'b00000_00000_11111;
		else
			o_data <= 15'b11111_00000_00000;
	end
	else
		o_data <= 15'b11111_11111_11111;
end

endmodule 
