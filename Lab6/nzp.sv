module nzp(
    input logic Clk, Reset,
    input logic [15:0] Bus,
    input logic LD_CC,
    output logic n,z,p
);

    logic n_Next, z_Next, p_Next;

    always_ff @ (posedge Clk)
    begin
        n <= n_Next;
        z <= z_Next;
        p <= p_Next;
    end

    always_comb
    begin
        n_Next = n;
        z_Next = z;
        p_Next = p;
	 	if (Reset)
            begin
			    n_Next <= 1'h0;
			    z_Next <= 1'h0;
			    p_Next <= 1'h0;
            end
		else if (LD_CC)
        begin
            if (Bus[15])
                begin
			        n_Next = 1'h1;
			        z_Next = 1'h0;
			        p_Next = 1'h0;
                end
            else if (16'h0===Bus)
                begin
                    n_Next = 1'h0;
			        z_Next = 1'h1;
			        p_Next = 1'h0;
                end
            else
                begin
                    n_Next = 1'h0;
			        z_Next = 1'h0;
			        p_Next = 1'h1;
                end
	    end
    end

endmodule