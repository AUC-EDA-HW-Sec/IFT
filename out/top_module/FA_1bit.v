module FA_1bit(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output Cout, Sum, Cout_t, Sum_t
);

	LUT3 #(.INIT(8'b11101000)) LUT_1 (
		.I0(A),
		.I1(B),
		.I2(Cin),
		.O(Cout)
	);

	LUT_e8 LUT_1_t(
		.I0(A),
		.I1(B),
		.I2(Cin),
		.I3(A_t),
		.I4(B_t),
		.I5(Cin_t),
		.O_t(Cout_t)
	);

	LUT3 #(.INIT(8'b10010110)) LUT_2 (
		.I0(A),
		.I1(B),
		.I2(Cin),
		.O(Sum)
	);

	LUT_96 LUT_2_t(
		.I0(A),
		.I1(B),
		.I2(Cin),
		.I3(A_t),
		.I4(B_t),
		.I5(Cin_t),
		.O_t(Sum_t)
	);

endmodule
