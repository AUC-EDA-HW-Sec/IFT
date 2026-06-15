module LUT_8(
	input a, b, a_t, b_t, 
	output c, c_t
);

	assign c = b & a;

	assign c_t = (b_t & a) 
		| (a_t & b) 
		| (a_t & b_t);

endmodule


//================================================================================

