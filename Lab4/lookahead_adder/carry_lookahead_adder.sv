// It's a 16-bit carry lookahead adder.

module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    logic [4:0] C, P, G; // Declare logic variable for c (carry bit), p (propagating logic) and g (generating logic).

    always_comb
    begin
        // Calculate all c_in directly.
        C[0] = 1'b0; // The first c_in is always 0.
        C[1] = C[0] & P[0] | G[0];
        C[2] = C[0] & P[0] & P[1] | G[0] & P[1] | G [1];
        C[3] = C[0] & P[0] & P[1] & P[2] | G[0] & P[1] & P[2] | G [1] & P[2] | G[2];
        // The final c_out is considered and calculated as the c_in of the next module.
        CO = C[0] & P[0] & P[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3] | G [1] & P[2] & P[3] | G[2] & P[3] | G[3];
    end
    
    // Instantiate and use 4 4-bit carry lookahead adders.
    adder4 AD0(.A(A[3:0]),.B(B[3:0]),.Cin(C[0]),.S(Sum[3:0]),.Cout(),.Pg(P[0]),.Gg(G[0]));
    adder4 AD1(.A(A[7:4]),.B(B[7:4]),.Cin(C[1]),.S(Sum[7:4]),.Cout(),.Pg(P[1]),.Gg(G[1]));
    adder4 AD2(.A(A[11:8]),.B(B[11:8]),.Cin(C[2]),.S(Sum[11:8]),.Cout(),.Pg(P[2]),.Gg(G[2]));
    adder4 AD3(.A(A[15:12]),.B(B[15:12]),.Cin(C[3]),.S(Sum[15:12]),.Cout(),.Pg(P[3]),.Gg(G[3]));
     
endmodule
