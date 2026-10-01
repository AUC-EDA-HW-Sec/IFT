module LUT4 #(parameter INIT = 16'b0) (
    input I0, I1, I2, I3,
    output O
);
    wire [3:0] idx = {I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_f888(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I4 & I6 & I3) 
		| (I6 & I3 & ~I0) 
		| (I4 & ~I2 & I1) 
		| (I7 & ~I1 & I6) 
		| (I4 & I5 & ~I3) 
		| (I4 & I5 & ~I2) 
		| (I2 & I7 & ~I1) 
		| (I5 & ~I2 & I0) 
		| (I7 & I6 & ~I0) 
		| (I5 & I2 & I7) 
		| (~I1 & I6 & I3) 
		| (I4 & I2 & I7) 
		| (I2 & I7 & ~I0) 
		| (I4 & I1 & ~I3) 
		| (I5 & ~I3 & I0) 
		| (I5 & I6 & I3);

endmodule


//================================================================================

module aoi22(
	input a0, a1, b0, b1, a0_t, a1_t, b0_t, b1_t, 
	output y, y_t
);

	LUT4 #(.INIT(16'b1111100010001000)) LUT_1 (
		.I0(b0),
		.I1(b1),
		.I2(a0),
		.I3(a1),
		.O(y)
	);

	LUT_f888 LUT_1_t(
		.I0(b0),
		.I1(b1),
		.I2(a0),
		.I3(a1),
		.I4(b0_t),
		.I5(b1_t),
		.I6(a0_t),
		.I7(a1_t),
		.O_t(y_t)
	);


`ifdef FORMAL
	always @(*) begin
		`ifdef TAINT_a0
			assume (a0_t == 1'b1);
			assume (a1_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
		`endif
		`ifdef TAINT_a1
			assume (a1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
		`endif
		`ifdef TAINT_b0
			assume (b0_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (b1_t == 1'b0);
		`endif
		`ifdef TAINT_b1
			assume (b1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (b0_t == 1'b0);
		`endif

		// Isolated Output Assertions
		`ifdef CHECK_y
			assert (y_t == 1'b0);
		`endif
	end
`endif

endmodule

