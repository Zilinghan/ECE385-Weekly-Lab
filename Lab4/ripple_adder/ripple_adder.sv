// It's a 16-bit ripple adder.

module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    logic [2:0] c;
    four_ripple_adder FR0(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Cout(c[0]),.S(Sum[3:0]));
    four_ripple_adder FR1(.A(A[7:4]), .B(B[7:4]), .Cin(c[0]), .Cout(c[1]),.S(Sum[7:4]));
    four_ripple_adder FR2(.A(A[11:8]), .B(B[11:8]), .Cin(c[1]), .Cout(c[2]),.S(Sum[11:8]));
    four_ripple_adder FR3(.A(A[15:12]), .B(B[15:12]), .Cin(c[2]), .Cout(CO),.S(Sum[15:12]));
     
endmodule
