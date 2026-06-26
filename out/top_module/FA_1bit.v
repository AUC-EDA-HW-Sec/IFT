module FA_1bit(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Sum, Cout_t, Sum_t
);

	LUT_e8 LUT_1(
		.I0(A),
		.I1(B),
		.I2(Cin),
		.I3(A_t),
		.I4(B_t),
		.I5(Cin_t),
		.O(Cout),
		.O_t(Cout_t)
	);

	LUT_96 LUT_2(
		.I0(A),
		.I1(B),
		.I2(Cin),
		.I3(A_t),
		.I4(B_t),
		.I5(Cin_t),
		.O(Sum),
		.O_t(Sum_t)
	);

endmodule
