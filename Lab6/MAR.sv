module MAR(
    input logic Clk, Reset,
    input logic [15:0] Bus,
    input logic LD_MAR,
    output logic [15:0] MAR
);

    logic [15:0] MAR_Next;

    always_ff @ (posedge Clk)
    begin
        MAR <= MAR_Next;
    end

    always_comb
    begin
        MAR_Next = MAR;
	 	if (Reset)
			MAR_Next = 16'h0;
		else if (LD_MAR)
			MAR_Next = Bus;
    end

endmodule