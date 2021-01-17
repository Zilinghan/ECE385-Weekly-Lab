module IR(
    input logic Clk, Reset,
    input logic [15:0] Bus,
    input logic LD_IR,
    output logic [15:0] IR
);

    logic [15:0] IR_Next;

    always_ff @ (posedge Clk)
    begin
        IR <= IR_Next;
    end

    always_comb
    begin
        IR_Next = IR;
	 	if (Reset)
			IR_Next = 16'h0;
		else if (LD_IR)
			IR_Next = Bus;
    end

endmodule