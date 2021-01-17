module RegFile(
    input logic Clk, Reset,
    input logic [15:0] Bus,
    input logic [2:0] DR, SR1, SR2,
    input logic LD_REG,
    output logic [15:0] SR1_OUT, SR2_Out
);

    logic [15:0] Reg[8];

    always_ff @ (posedge Clk)
    begin
	 	if (Reset)
            for(int i = 0; i < 8; i++)
            begin
                Reg[i] <= 16'h0;
            end
		else if (LD_REG)
            Reg[DR] <= Bus;
    end

    assign SR1_OUT = Reg[SR1];
    assign SR2_Out = Reg[SR2];

endmodule