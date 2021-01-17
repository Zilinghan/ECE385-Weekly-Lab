module MDR(
    input logic Clk, Reset,
    input logic [15:0] Bus, MDR_In,
    input logic LD_MDR, MIO_EN,
    output logic [15:0] MDR
);

    logic [15:0] MDR_Next;

    always_ff @ (posedge Clk)
    begin
        MDR <= MDR_Next;
    end

    always_comb
    begin
        MDR_Next = MDR;
	 	if (Reset)
			MDR_Next = 16'h0;
		else if (LD_MDR)
			unique case (MIO_EN)
                1'b0: MDR_Next = Bus;
                1'b1: MDR_Next = MDR_In;
            endcase
    end

endmodule