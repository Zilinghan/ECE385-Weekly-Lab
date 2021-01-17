module add_sub9
(
    input logic[7:0] A,B,
    input fn,
    output logic[8:0] S
);

    logic[7:0] c;
    logic[7:0] b_add;
    logic A8,b_add8;

    assign b_add=(B^{8{fn}});
    assign A8=A[7];
    assign b_add8=b_add[7];

    full_adder FA0(.x(A[0]), .y(b_add[0]), .z(fn), .c(c[0]), .s(S[0]));
    full_adder FA1(.x(A[1]), .y(b_add[1]), .z(c[0]), .c(c[1]), .s(S[1]));
    full_adder FA2(.x(A[2]), .y(b_add[2]), .z(c[1]), .c(c[2]), .s(S[2]));
    full_adder FA3(.x(A[3]), .y(b_add[3]), .z(c[2]), .c(c[3]), .s(S[3]));
    full_adder FA4(.x(A[4]), .y(b_add[4]), .z(c[3]), .c(c[4]), .s(S[4]));
    full_adder FA5(.x(A[5]), .y(b_add[5]), .z(c[4]), .c(c[5]), .s(S[5]));
    full_adder FA6(.x(A[6]), .y(b_add[6]), .z(c[5]), .c(c[6]), .s(S[6]));
    full_adder FA7(.x(A[7]), .y(b_add[7]), .z(c[6]), .c(c[7]), .s(S[7]));
    full_adder FA8(.x(A8), .y(b_add8), .z(c[7]), .c(), .s(S[8]));

endmodule
