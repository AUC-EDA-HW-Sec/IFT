module LUT_e8(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Cout_t
);

	assign Cout = (Cin & B) 
		| (A & Cin) 
		| (A & B);

	assign Cout_t = (B_t & ~A & Cin) 
		| (A_t & B_t) 
		| (B_t & Cin_t) 
		| (Cin_t & A & ~B) 
		| (Cin_t & ~A & B) 
		| (B_t & A & ~Cin) 
		| (A_t & Cin_t) 
		| (A_t & Cin & ~B) 
		| (A_t & ~Cin & B);

endmodule


//================================================================================

module LUT_96(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Sum, Sum_t
);

	assign Sum = (A & Cin & B) 
		| (~A & ~Cin & B) 
		| (A & ~Cin & ~B) 
		| (~A & Cin & ~B);

	assign Sum_t = A_t | B_t | Cin_t;

endmodule


//================================================================================

