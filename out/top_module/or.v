module LUT2 #(parameter INIT = 4'b0) (
    input I0, I1,
    output O
);
    wire [1:0] idx = {I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_e(
	input I0, I1, I2, I3, 
	output O_t
);

	assign O_t = (I2 & ~I1) 
		| (I2 & I3) 
		| (I3 & ~I0);

endmodule


//================================================================================

module or(
	input a, b, a_t, b_t, 
	output c, c_t
);

	LUT2 #(.INIT(4'b1110)) LUT_1 (
		.I0(a),
		.I1(b),
		.O(c)
	);

	LUT_e LUT_1_t(
		.I0(a),
		.I1(b),
		.I2(a_t),
		.I3(b_t),
		.O_t(c_t)
	);

endmodule
