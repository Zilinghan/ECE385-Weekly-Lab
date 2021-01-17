// It's a 4-bit carry lookahead adder.

module adder4
(
    input logic [3:0] A,
    input logic [3:0] B,
    input logic Cin,
    output logic [3:0] S,
    output logic Cout,
    output logic Pg,
    output logic Gg
);
    logic [4:0] C, P, G; // Declare logic variable for c (carry bit), p (propagating logic) and g (generating logic).

    always_comb
    begin
        // Calculate all c_in directly.
        C[0] = Cin;
        C[1] = Cin & P[0] | G[0];
        C[2] = Cin & P[0] & P[1] | G[0] & P[1] | G [1];
        C[3] = Cin & P[0] & P[1] & P[2] | G[0] & P[1] & P[2] | G [1] & P[2] | G[2];
        // The final c_out is considered and calculated as the c_in of the next module.
        Cout = Cin & P[0] & P[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3] | G [1] & P[2] & P[3] | G[2] & P[3] | G[3];
        // Calculate the Pg (group propagating logic) and Gg (group generating logic).
        Pg = P[0] & P[1] & P[2] & P[3];
        Gg = G[3] | G[2] & P[3] | G[1] & P[3] & P[2] | G[0] & P[3] & P[2] & P[1];
    end
    
    // Instantiate and use 4 full adders, which can also generate the p (propagating logic) and g (generating logic).
    full_adder FA0(.x(A[0]),.y(B[0]),.z(C[0]),.c(),.s(S[0]),.p(P[0]),.g(G[0]));
    full_adder FA1(.x(A[1]),.y(B[1]),.z(C[1]),.c(),.s(S[1]),.p(P[1]),.g(G[1]));
    full_adder FA2(.x(A[2]),.y(B[2]),.z(C[2]),.c(),.s(S[2]),.p(P[2]),.g(G[2]));
    full_adder FA3(.x(A[3]),.y(B[3]),.z(C[3]),.c(),.s(S[3]),.p(P[3]),.g(G[3]));

endmodule