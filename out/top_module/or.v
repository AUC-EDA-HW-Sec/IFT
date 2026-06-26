module or(
	input a, b, a_t, b_t, 
	output c, c_t
);

	LUT_e LUT_1(
		.I0(a),
		.I1(b),
		.I2(a_t),
		.I3(b_t),
		.O(c),
		.O_t(c_t)
	);

endmodule
