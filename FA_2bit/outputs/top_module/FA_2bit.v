module LUT3 #(parameter INIT = 8'b0) (
    input I0, I1, I2,
    output O
);
    wire [2:0] idx = {I2, I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_17(
	input I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, 
	output O_t
);

	assign O_t = (I4 & ~I2 & I0) 
		| (I3 & I5) 
		| (I4 & I2 & ~I0) 
		| (I4 & I5) 
		| (I3 & I2 & ~I1) 
		| (I3 & I4) 
		| (I0 & I5 & ~I1) 
		| (~I0 & I5 & I1) 
		| (I3 & ~I2 & I1);

endmodule


//================================================================================

module LUT_8e(
	input I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, 
	output O_t
);

	assign O_t = (I4 & ~I2 & ~I0) 
		| (I3 & I5) 
		| (I4 & I5) 
		| (I3 & I2 & ~I1) 
		| (I3 & I4) 
		| (~I0 & I5 & ~I1) 
		| (I0 & I5 & I1) 
		| (I3 & ~I2 & I1) 
		| (I4 & I2 & I0);

endmodule


//================================================================================

module LUT_96(
	input I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, 
	output O_t
);

	assign O_t = I3 | I4 | I5;

endmodule


//================================================================================

module LUT_69(
	input I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, 
	output O_t
);

	assign O_t = I3 | I4 | I5;

endmodule


//================================================================================

module FA_2bit(
	input a0, a1, b0, b1, cin, a0_t, a1_t, b0_t, b1_t, cin_t, 
	output wire cout_$lut_Y_A_output, cout_output, sum0_output, sum1_output, cout_$lut_Y_A_t_output, cout_t_output, sum0_t_output, sum1_t_output
);

	wire cout_$lut_Y_A, cout, sum0, sum1, cout_$lut_Y_A_t, cout_t, sum0_t, sum1_t;

	assign cout_$lut_Y_A_output = cout_$lut_Y_A;
	assign cout_output = cout;
	assign sum0_output = sum0;
	assign sum1_output = sum1;
	assign cout_$lut_Y_A_t_output = cout_$lut_Y_A_t;
	assign cout_t_output = cout_t;
	assign sum0_t_output = sum0_t;
	assign sum1_t_output = sum1_t;

	LUT3 #(.INIT(8'b00010111)) LUT_1 (
		.I0(a0),
		.I1(b0),
		.I2(cin),
		.O(cout_$lut_Y_A)
	);

	LUT_17 LUT_1_t(
		.I0(a0),
		.I1(b0),
		.I2(cin),
		.O_t(cout_$lut_Y_A_t)
	);

	LUT3 #(.INIT(8'b10001110)) LUT_2 (
		.I0(cout_$lut_Y_A),
		.I1(a1),
		.I2(b1),
		.O(cout)
	);

	LUT_8e LUT_2_t(
		.I0(cout_$lut_Y_A),
		.I1(a1),
		.I2(b1),
		.O_t(cout_t)
	);

	LUT3 #(.INIT(8'b10010110)) LUT_3 (
		.I0(a0),
		.I1(b0),
		.I2(cin),
		.O(sum0)
	);

	LUT_96 LUT_3_t(
		.I0(a0),
		.I1(b0),
		.I2(cin),
		.O_t(sum0_t)
	);

	LUT3 #(.INIT(8'b01101001)) LUT_4 (
		.I0(cout_$lut_Y_A),
		.I1(a1),
		.I2(b1),
		.O(sum1)
	);

	LUT_69 LUT_4_t(
		.I0(cout_$lut_Y_A),
		.I1(a1),
		.I2(b1),
		.O_t(sum1_t)
	);


`ifdef FORMAL
	always @(*) begin
		`ifdef TAINT_a0
			assume (a0_t == 1'b1);
			assume (a1_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (cin_t == 1'b0);
		`endif
		`ifdef TAINT_a1
			assume (a1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (cin_t == 1'b0);
		`endif
		`ifdef TAINT_b0
			assume (b0_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (cin_t == 1'b0);
		`endif
		`ifdef TAINT_b1
			assume (b1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (cin_t == 1'b0);
		`endif
		`ifdef TAINT_cin
			assume (cin_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
		`endif

		// Isolated Output Assertions
		`ifdef CHECK_cout_$lut_Y_A
			assert (cout_$lut_Y_A_t == 1'b0);
		`endif
		`ifdef CHECK_cout
			assert (cout_t == 1'b0);
		`endif
		`ifdef CHECK_sum0
			assert (sum0_t == 1'b0);
		`endif
		`ifdef CHECK_sum1
			assert (sum1_t == 1'b0);
		`endif
	end
`endif

endmodule

