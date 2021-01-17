module PC(
    input logic Clk, Reset,
    input logic [15:0] PCMUX_Out,
    input logic LD_PC,
    output logic [15:0] PC
);

    logic [15:0] PC_Next;

    always_ff @ (posedge Clk)
    begin
        PC <= PC_Next;
    end

    always_comb
    begin
        PC_Next = PC;
	 	if (Reset)
			PC_Next = 16'h0;
		else if (LD_PC)
			PC_Next = PCMUX_Out;
    end

endmodule