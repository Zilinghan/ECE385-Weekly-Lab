// It's a 16-bit carry select adder.

module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    
    logic [3:0] c, c0, c1; // Declare two kinds of c_out and the real c_out.
    logic [15:0] s0, s1; // Declare two kinds of sum.
    // Instantiate and use 7 4-bit ripple adders.
    four_ripple_adder FR0(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Cout(c0[0]),.S(s0[3:0]));
    four_ripple_adder FR2(.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Cout(c0[1]),.S(s0[7:4]));
    four_ripple_adder FR3(.A(A[7:4]), .B(B[7:4]), .Cin(1'b1), .Cout(c1[1]),.S(s1[7:4]));
    four_ripple_adder FR4(.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Cout(c0[2]),.S(s0[11:8]));
    four_ripple_adder FR5(.A(A[11:8]), .B(B[11:8]), .Cin(1'b1), .Cout(c1[2]),.S(s1[11:8]));
    four_ripple_adder FR6(.A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Cout(c0[3]),.S(s0[15:12]));
    four_ripple_adder FR7(.A(A[15:12]), .B(B[15:12]), .Cin(1'b1), .Cout(c1[3]),.S(s1[15:12]));
    
    always_comb
    begin
        // Combinational logic for the next c_in.
        c[0] = c0[0];
        c[1] = c0[1] | c1[1] & c[0];
        c[2] = c0[2] | c1[2] & c[1];
        c[3] = c0[3] | c1[3] & c[2];
        CO = c[3];
        // Mux to select sum.
        Sum[3:0] = s0[3:0]; // The lowest significant 4 bits are always the sum from 0 c_in.
        unique case (c[0])
            1'b0: Sum[7:4] = s0[7:4];
            1'b1: Sum[7:4] = s1[7:4];
            default: Sum[7:4] = 4'bxxxx;
        endcase
        unique case (c[1])
            1'b0: Sum[11:8] = s0[11:8];
            1'b1: Sum[11:8] = s1[11:8];
            default: Sum[11:8] = 4'bxxxx;
        endcase
        unique case (c[2])
            1'b0: Sum[15:12] = s0[15:12];
            1'b1: Sum[15:12] = s1[15:12];
            default: Sum[15:12] = 4'bxxxx;
        endcase
    end
     
endmodule
