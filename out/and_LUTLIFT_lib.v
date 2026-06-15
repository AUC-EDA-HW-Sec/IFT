module LUT_8(
	input a, b, a_t, b_t, 
	output c, c_t
);

	assign c = a & b;

	assign c_t = (a & b_t) 
		| (a_t & b) 
		| (b_t & a_t);

endmodule


//================================================================================

