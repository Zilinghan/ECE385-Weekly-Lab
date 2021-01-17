module testbench_avalon_aes_interface();
	// half clock cycle at 50 MHz
	// this is the amount of time represented by #1 delay
	timeunit 10ns;
	timeprecision 1ns;

	// internal variables
	logic Clk;
	logic RESET;
	logic AVL_READ;
	logic AVL_WRITE;
	logic AVL_CS;
	logic [3:0] AVL_BYTE_EN;
	logic [3:0] AVL_ADDR;
	logic [31:0] AVL_WRITEDATA;
	logic [31:0] AVL_READDATA;
	logic [31:0] EXPORT_DATA;

	// initialize the toplevel entity
	avalon_aes_interface avalon_aes_interface_test(.CLK(Clk),.RESET(RESET),.AVL_READ(AVL_READ),.AVL_WRITE(AVL_WRITE),.AVL_CS(AVL_CS),.AVL_BYTE_EN(AVL_BYTE_EN),.AVL_ADDR(AVL_ADDR),.AVL_WRITEDATA(AVL_WRITEDATA),.AVL_READDATA(AVL_READDATA),.EXPORT_DATA(EXPORT_DATA));
	
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
	//AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;
	//AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;

	RESET = 1'b1;
	AVL_READ = 1'b0;
	AVL_WRITE = 1'b0;
	AVL_CS = 1'b0;

	#2 RESET = 1'b0;

	#2 AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h00010203;
	AVL_ADDR = 4'd0;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h04050607;
	AVL_ADDR = 4'd1;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h08090a0b;
	AVL_ADDR = 4'd2;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h0c0d0e0f;
	AVL_ADDR = 4'd3;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'hdaec3055;
	AVL_ADDR = 4'd4;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'hdf058e1c;
	AVL_ADDR = 4'd5;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h39e814ea;
	AVL_ADDR = 4'd6;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h76f6747e;
	AVL_ADDR = 4'd7;
	AVL_CS = 1'b1;

	#10	AVL_WRITE = 1'b1;
	AVL_BYTE_EN = 4'b1111;
	AVL_WRITEDATA =  32'h0000001;
	AVL_ADDR = 4'd14;
	AVL_CS = 1'b1;

	end
	 
endmodule
