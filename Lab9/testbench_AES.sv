module testbench_AES();
	// half clock cycle at 50 MHz
	// this is the amount of time represented by #1 delay
	timeunit 10ns;
	timeprecision 1ns;

	// internal variables
	logic Clk;
	logic RESET;
	logic AES_START;
	logic AES_DONE;
	logic [127:0] AES_KEY;
	logic [127:0] AES_MSG_ENC;
	logic [127:0] AES_MSG_DEC;

	// initialize the toplevel entity
	AES AES_test(.CLK(Clk),.RESET(RESET),.AES_START(AES_START),.AES_DONE(AES_DONE),.AES_KEY(AES_KEY),.AES_MSG_ENC(AES_MSG_ENC),.AES_MSG_DEC(AES_MSG_DEC));
	
	// set clock rule
	always begin : CLOCK_GENERATION 
		#1 Clk = ~Clk;
	end
	
	// initialize clock signal 
	initial begin: CLOCK_INITIALIZATION 
		Clk = 0;
	end
	
	// begin testing
	initial begin: TEST_VECTORS
	AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;
	AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;
	RESET = 1'b1;

	#2 RESET = 1'b0;

	#2 AES_START = 1'b1;
	end
	 
endmodule
