// It's a full adder, which can also generate the p (propagating logic) and g (generating logic).

module full_adder(input logic x,y,z, output logic c,s,p,g);
	always_comb
	begin
		s=x^y^z;
		c=(x&y)|(y&z)|(z&x); 
		p=x^y;
		g=x&y;
	end
endmodule
