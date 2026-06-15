module LUT_e(
	input a, b, a_t, b_t, 
	output c, c_t
);

	assign c = a | b;

	assign c_t = (b_t & a_t) 
		| (a_t & ~b) 
		| (~a & b_t);

endmodule


//================================================================================

