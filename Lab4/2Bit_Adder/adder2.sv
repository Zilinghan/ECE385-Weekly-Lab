module adder2(input [1:0] A,B, input Cin, output logic [1:0] Sum, output logic Cout);
	logic c1;
	full_adder FA0(.x(A[0]), .y(B[0]), .z(Cin), .c(c1), .s(Sum[0]));
	full_adder FA1(.x(A[1]), .y(B[1]), .z(c1), .c(Cout), .s(Sum[1]));
endmodule
