module and(
	input a, b, a_t, b_t, 
	output c, c_t
);

	LUT2 #(.INIT(4'b1000)) LUT_1 (
		.I0(a),
		.I1(b),
		.O(c)
	);

	LUT_8 LUT_1_t(
		.I0(a),
		.I1(b),
		.I2(a_t),
		.I3(b_t),
		.O_t(c_t)
	);

endmodule
