module BEN(
    input logic Clk, Reset,
    input logic n,z,p,
    input logic [2:0] IR_11_9,
    input logic LD_BEN,
    output logic BEN
);

    logic BEN_Next;

    always_ff @ (posedge Clk)
    begin
        BEN <= BEN_Next;
    end

    always_comb
    begin
        BEN_Next = BEN;
	 	if (Reset)
			BEN_Next = 1'h0;
		else if (LD_BEN)
			BEN_Next = (n && IR_11_9[2]) || (z && IR_11_9[1]) || (p && IR_11_9[0]);
    end

endmodule