module full_adder(input x,y,z, output logic c,s);
	always_comb
	begin
		s=x^y^z;
		c=(x&y)|(y&z)|(z&x);
	end
endmodule
