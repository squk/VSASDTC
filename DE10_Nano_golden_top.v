//`define ENABLE_HPS

module DE10_Nano_golden_top(

      ///////// ADC /////////
      output             ADC_CONVST,
      output             ADC_SCK,
      output             ADC_SDI,
      input              ADC_SDO,

      ///////// ARDUINO /////////
      inout       [15:0] ARDUINO_IO,
      inout              ARDUINO_RESET_N,

      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// GPIO /////////
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

      ///////// HDMI /////////
      inout              HDMI_I2C_SCL,
      inout              HDMI_I2C_SDA,
      inout              HDMI_I2S,
      inout              HDMI_LRCLK,
      inout              HDMI_MCLK,
      inout              HDMI_SCLK,
      output             HDMI_TX_CLK,
      output      [23:0] HDMI_TX_D,
      output             HDMI_TX_DE,
      output             HDMI_TX_HS,
      input              HDMI_TX_INT,
      output             HDMI_TX_VS,

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW
);

wire ce25;
wire gba_xtal;
wire reset;
wire READY;

assign reset = ~KEY[0];

// audio signals
assign HDMI_I2S0  = 1'b z;
assign HDMI_MCLK  = 1'b z;
assign HDMI_LRCLK = 1'b z;
assign HDMI_SCLK  = 1'b z;

// **VGA CLOCK**
clock_div #( .NTH_CLOCK(2) ) div2(
  .in(FPGA_CLK1_50),
  .rst(reset),

  .out(ce25)
);

// GBA's crystal clock
 clock_div #( .NTH_CLOCK(12) ) div_xtal (
  .in(FPGA_CLK1_50),
  .rst(reset),

  .out(gba_xtal)
);
 

wire [14:0] gba_rgb;
wire [14:0] hdmi_rgb;
wire [15:0] rdaddr;
wire [15:0] wraddr;
wire wrclk, write_enable;
	
ram_infer ram_infer(
	.data(gba_rgb),
	.read_addr(rdaddr),
	.write_addr(wraddr),
	.we(write_enable),
	.clk(FPGA_CLK1_50),
	.q(hdmi_rgb)
);
 
gba_fb gba_fb(
	.i_rst(reset),
	.i_clk(gba_xtal),
	
	.i_DCLK(GPIO_0[0]),
	.i_LP (GPIO_0[1]),
	.i_SPL(GPIO_0[2]),
	.i_CLS(GPIO_0[3]), 
	.i_SPS(GPIO_0[4]),
	.i_R(GPIO_1[4:0]), // 5-bit Red
	.i_G(GPIO_0[9:5]), // 5-bit Green
	.i_B(GPIO_0[23:18]), // 5-bit Blue
	
	.o_wre(write_enable),
	.o_wraddr(wraddr),
	.o_data(gba_rgb),
	
	.o_LED(LED)
//	.o_LED(GPIO_1[35:28])
);

//test_fb test_fb(
//	.i_rst(reset),
//	.i_clk(gba_xtal),
//	.i_DCLK(GPIO_0[0]),
//	.i_LP(GPIO_0[1]),
//	.i_SPL(GPIO_0[3]),
//	.i_CLS(GPIO_0[4]), 
//	.i_SPS(GPIO_0[5]), 
//	.i_MOD(GPIO_0[6]), 
//	.i_VCOM(GPIO_0[7]),
//	.i_R(GPIO_0[24:20]), // 5-bit Red
//	.i_G(GPIO_0[29:25]), // 5-bit Green
//	.i_B(GPIO_0[34:30]), // 5-bit Blue
//	
//	.o_wre(write_enable),
//	.o_wrclk(wrclk),
//	.o_wraddr(wraddr),
//	.o_data(gba_rgb),
//	.o_LED(LED)
////	.o_LED(GPIO_1[35:28])
//);

//end

// **VGA MAIN CONTROLLER**
vgaHdmi vgaHdmi (
	.i_ce25      (ce25),
	.i_clock50    (FPGA_CLK1_50),
	.i_reset      (~locked),
	.i_RGB(hdmi_rgb),

	.o_hsync      (HDMI_TX_HS),
	.o_vsync      (HDMI_TX_VS),
	.o_dataEnable (HDMI_TX_DE),
	.o_vgaClock   (HDMI_TX_CLK),
	.o_RGBchannel (HDMI_TX_D),
	.o_rdaddr(rdaddr)
);

// **I2C Interface for ADV7513 initial config**
I2C_HDMI_Config #(
  .CLK_Freq (50000000), // 50MHz
  .I2C_Freq (20000)    // 20kHz for i2c clock
)

I2C_HDMI_Config (
	.iCLK        (FPGA_CLK1_50),
	.iRST_N      (~reset),
	.I2C_SCLK    (HDMI_I2C_SCL),
	.I2C_SDAT    (HDMI_I2C_SDA),
	.HDMI_TX_INT (HDMI_TX_INT),
	.READY       (READY)
);

assign ARDUINO_IO = gba_xtal;

endmodule
