module FA_1bit(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Sum, Cout_t, Sum_t
);

	LUT_e8 LUT_1(
		.A(A),
		.B(B),
		.Cin(Cin),
		.A_t(A_t),
		.B_t(B_t),
		.Cin_t(Cin_t),
		.Cout(Cout),
		.Cout_t(Cout_t)
	);

	LUT_96 LUT_2(
		.A(A),
		.B(B),
		.Cin(Cin),
		.A_t(A_t),
		.B_t(B_t),
		.Cin_t(Cin_t),
		.Sum(Sum),
		.Sum_t(Sum_t)
	);

endmodule
