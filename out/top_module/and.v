module LUT2 #(parameter INIT = 4'b0) (
    input I0, I1,
    output O
);
    wire [1:0] idx = {I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_8(
	input I0, I1, I2, I3, 
	output O_t
);

	assign O_t = (I3 & I0) 
		| (I2 & I1) 
		| (I2 & I3);

endmodule


//================================================================================

module and_top(
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


`ifdef FORMAL
	always @(*) begin
		`ifdef TAINT_a
			assume (a_t == 1'b1);
			assume (b_t == 1'b0);
		`endif
		`ifdef TAINT_b
			assume (b_t == 1'b1);
			assume (a_t == 1'b0);
		`endif

		// Isolated Output Assertions
		`ifdef CHECK_c
			assert (c_t == 1'b0);
		`endif
	end
`endif

endmodule

