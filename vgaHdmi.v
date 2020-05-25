module vgaHdmi(
	input i_ce25, i_clock50, i_reset,
	
	input [14:0] i_RGB,

	output reg [15:0] o_rdaddr,
	output reg o_hsync, o_vsync,
	output reg o_vgaClock,
	output reg o_dataEnable,
	output reg [23:0] o_RGBchannel
);

reg [9:0]pixelH, pixelV;

initial begin
	o_hsync      = 1;
	o_vsync      = 1;
	pixelH     = 0;
	pixelV     = 0;
	o_dataEnable = 0;
end

always @(posedge i_clock50) begin
	if(i_reset) begin
		 o_hsync  <= 1;
		 o_vsync  <= 1;
		 pixelH <= 0;
		 pixelV <= 0;
	end
	else if (i_ce25) begin
		 // Display Horizontal
		if(pixelH==0 && pixelV!=524) begin
			pixelH <= pixelH + 1'b1;
			pixelV <= pixelV + 1'b1;
			
			if(pixelH < 240 && pixelV < 160) begin
				o_rdaddr <= o_rdaddr + 241;
			end
		end
		else if(pixelH == 0 && pixelV == 524) begin
			pixelH <= pixelH + 1'b1;
			pixelV <= 0; // pixel 525
			o_rdaddr <= 1;
		end
		else if(pixelH <= 640) begin
			pixelH <= pixelH + 1'b1;
			if(pixelH < 240 && pixelV < 160) begin
				o_rdaddr <= o_rdaddr + 1'b1;
			end
		end
		// Front Porch
		else if(pixelH <= 656)pixelH <= pixelH + 1'b1;
		// Sync Pulse
		else if(pixelH<=752) begin
			pixelH <= pixelH + 1'b1;
			o_hsync <= 0;
		end
		// Back Porch
		else if(pixelH < 799) begin
			pixelH <= pixelH + 1'b1;
			o_hsync <= 1;
			end
		else pixelH <= 0; // pixel 800

		// Sync Pulse
		if(pixelV == 491 || pixelV == 492)
			o_vsync <= 0;
		else
			o_vsync <= 1;
	end
	else begin
		o_rdaddr <= 0;
	end
end


always @(posedge i_clock50) begin
	if(i_reset) 
		o_dataEnable <= 0;
	else if (i_ce25 && (pixelH < 640 && pixelV < 480)) begin
		o_dataEnable <= 1;
		
		if(pixelH < 240 && pixelV < 160) begin
			o_RGBchannel[23:16] <= {i_RGB[4:0], i_RGB[4:2]};// equivalent to (i_RGB << 3) | i_RGB[4:2]
			o_RGBchannel[15:8] <= {i_RGB[9:5], i_RGB[9:7]};
			o_RGBchannel[7:0] <= {i_RGB[14:10], i_RGB[14:12]};
		end
		else begin
			o_RGBchannel[23:16] <= 5'd16;
			o_RGBchannel[15:8] <= 5'd16;
			o_RGBchannel[7:0] <= 5'd16;
		end
	end
	else o_dataEnable <= 0;
end

initial o_vgaClock = 0;

always @(posedge i_clock50) begin
  if(i_reset) o_vgaClock <= 0;
  else      o_vgaClock <= ~o_vgaClock;
end

endmodule
 