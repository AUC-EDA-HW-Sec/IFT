module and(
	input a, b, a_t, b_t, 
	output c, c_t
);

	LUT_8 LUT_1(
		.a(a),
		.b(b),
		.a_t(a_t),
		.b_t(b_t),
		.c(c),
		.c_t(c_t)
	);

endmodule
