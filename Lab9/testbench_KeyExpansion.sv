module testbench_KeyExpansion();
	// half clock cycle at 50 MHz
	// this is the amount of time represented by #1 delay
	timeunit 10ns;
	timeprecision 1ns;

	// internal variables
	logic Clk;
	logic [127:0] Cipherkey;
	logic [1407:0] KeySchedule;
	
	// initialize the toplevel entity
	KeyExpansion KeyExpansion_test(.clk(Clk),.Cipherkey(Cipherkey),.KeySchedule(KeySchedule));
	
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
	Cipherkey = 128'h000102030405060708090a0b0c0d0e0f;
	end
	 
endmodule
