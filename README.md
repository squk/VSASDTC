# VSASDTC
 verilog sucks and so does this code. 
 
GBA video to HDMI for Terasic DE10. 

NOTE: Oct 2024:

I'm making this code public because why not but it's not in any sort of finished state. 

This is an FPGA(Intel Verilog) implementation for decoding the video signal from a Gameboy Advance's(GBA) 40 or 34pin LCD connector. If I remember correctly, the `gba_fb` moduled decodes a single frame from the LCD interface, it gets written to the DE10's onboard RAM, then the `vga_hdmi` module reads the frame from RAM, does some super basic upscaling and outputs it. No idea how they maintained sync, if at all. IDK it's been 4 years. See here github.com/squk/GBA-LCD for my reverse engineered docs on the LCG signal. 

Better version : https://github.com/zwenergy/gbaHD
