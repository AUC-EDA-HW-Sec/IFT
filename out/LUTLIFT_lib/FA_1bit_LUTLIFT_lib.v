module LUT_e8(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Cout_t
);

	assign Cout = (B & Cin) 
		| (A & Cin) 
		| (A & B);

	assign Cout_t = (~A & B_t & Cin) 
		| (A_t & B_t) 
		| (Cin_t & B_t) 
		| (A & ~B & Cin_t) 
		| (~A & B & Cin_t) 
		| (A & B_t & ~Cin) 
		| (Cin_t & A_t) 
		| (~B & A_t & Cin) 
		| (B & A_t & ~Cin);

endmodule


//================================================================================

module LUT_96(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Sum, Sum_t
);

	assign Sum = (A & B & Cin) 
		| (~A & B & ~Cin) 
		| (A & ~B & ~Cin) 
		| (~A & ~B & Cin);

	assign Sum_t = Cin_t | A_t | B_t;

endmodule


//================================================================================

