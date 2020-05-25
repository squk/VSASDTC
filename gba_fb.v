// Gameboy Advance Framebuffer
// ingests 15-bit RGB pixel data and inserts into RAM
module gba_fb(
	input i_rst,
	input i_clk,
	
	// CLS = clock signal of source driver
	// SPS = start signal of gate driver
	// LP = latch signal of source driver
	// SPL = sampling start signal
	input i_DCLK,
	input i_LP, i_SPL, i_CLS, i_SPS,
	input [4:0] i_R, // 5-bit Red
	input [4:0] i_G, // 5-bit Green
	input [4:0] i_B, // 5-bit Blue
	
	output wire o_wre, 
	output reg [15:0] o_wraddr,
	output reg [14:0] o_data,
	output wire [7:0] o_LED
);

assign o_wre = 1;

reg [7:0] frames;
reg [7:0] dclk_count, cls_count, lp_count;
reg [7:0] v_count, h_count;

// In RAM:
// 15'b11111_00000_00000 = RED
// 15'b00000_11111_00000 = GREEN
// 15'b00000_00000_11111 = BLUE
always @ (negedge i_DCLK) begin;
	if (i_SPL) begin
		dclk_count <= 0;
		h_count <= 0;
		o_wraddr <= (240 * 160) + 1;
	end
	else begin
		dclk_count <= dclk_count + 1'b1;
		h_count <= h_count + 1'b1;
		
		o_wraddr <= (128*v_count + 64*v_count + 32*v_count + 16*v_count) + h_count;
		o_data <= {i_R, i_G, i_B};
	end
end

always @ (negedge i_LP) begin
	if (!i_SPS) begin// new frame
		lp_count <= 0;
	end
	else begin
		lp_count <= lp_count + 1'b1;
	end
end

always @ (posedge i_SPL) begin // new line
	if (lp_count == 5) begin
		v_count <= 0;
	end
	else begin
		v_count <= v_count + 1'b1;
	end
end
endmodule 
