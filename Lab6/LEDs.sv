module LEDs(
    input logic Clk, Reset,
    input logic [11:0] IR_11_0,
    input logic LD_LED,
    output logic [11:0] LED
);

    logic [11:0] LED_Next;

    always_ff @ (posedge Clk)
    begin
        LED <= LED_Next;
    end

    always_comb
    begin
        LED_Next = LED;
	 	if (Reset)
			LED_Next = 12'h0;
		else if (LD_LED)
			LED_Next = IR_11_0;
    end

endmodule