module extend_bit
(
    input Clk, ld, Reset, D,
    output logic Q
);

    always_ff @ (posedge Clk)
    begin
        if (Reset)
            Q <= 1'b0;
        else
            if (ld)
                Q <= D;
            else
                Q <= Q;
    end

endmodule
