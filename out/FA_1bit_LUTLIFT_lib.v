module LUT_e8(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Cout_t
);

	assign Cout = (B & Cin) 
		| (A & Cin) 
		| (B & A);

	assign Cout_t = (~A & B_t & Cin) 
		| (A_t & B_t) 
		| (Cin_t & B_t) 
		| (~B & Cin_t & A) 
		| (B & Cin_t & ~A) 
		| (A & B_t & ~Cin) 
		| (A_t & Cin_t) 
		| (A_t & ~B & Cin) 
		| (A_t & B & ~Cin);

endmodule


//================================================================================

module LUT_96(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Sum, Sum_t
);

	assign Sum = (B & A & Cin) 
		| (B & ~A & ~Cin) 
		| (~B & A & ~Cin) 
		| (~B & ~A & Cin);

	assign Sum_t = A_t | Cin_t | B_t;

endmodule


//================================================================================

