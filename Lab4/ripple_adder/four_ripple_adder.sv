// It's a 4-bit ripple adder.

module four_ripple_adder
(
    input logic[3:0] A,
    input logic[3:0] B,
    input logic Cin,
    output logic Cout,
    output logic[3:0] S
);
    logic [2:0] c;
    full_adder FA0(.x(A[0]), .y(B[0]), .z(Cin), .c(c[0]), .s(S[0]));
    full_adder FA1(.x(A[1]), .y(B[1]), .z(c[0]), .c(c[1]), .s(S[1]));
    full_adder FA2(.x(A[2]), .y(B[2]), .z(c[1]), .c(c[2]), .s(S[2]));
    full_adder FA3(.x(A[3]), .y(B[3]), .z(c[2]), .c(Cout), .s(S[3]));
endmodule