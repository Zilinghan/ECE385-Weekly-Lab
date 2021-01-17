module full_adder (input a, b, cin, output s, cout);

	// Typical single-bit full adder.

	// Truth Table
	//
	// Cin A B | S Cout
	//   0 0 0 | 0 0
	//   0 0 1 | 1 0
	//   0 1 0 | 1 0
	//   0 1 1 | 0 1
	//   1 0 0 | 1 0
	//   1 0 1 | 0 1
	//   1 1 0 | 0 1
	//   1 1 1 | 1 1

	assign s = a ^ b ^ cin;
	assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
