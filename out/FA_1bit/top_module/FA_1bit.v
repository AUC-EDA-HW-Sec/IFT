module LUT3 #(parameter INIT = 8'b0) (
    input I0, I1, I2,
    output O
);
    wire [2:0] idx = {I2, I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_e8(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & I0 & ~I2) 
		| (I3 & I5) 
		| (I4 & ~I0 & I2) 
		| (I4 & I5) 
		| (I3 & I2 & ~I1) 
		| (I3 & I4) 
		| (I5 & I0 & ~I1) 
		| (I5 & ~I0 & I1) 
		| (I3 & ~I2 & I1);

endmodule


//================================================================================

module LUT_96(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I3 | I4 | I5;

endmodule


//================================================================================

module FA_1bit(
	input A, B, Cin, A_t, B_t, Cin_t, 
	output wire Cout_output, Sum_output, Cout_t_output, Sum_t_output
);

	wire Cout, Sum, Cout_t, Sum_t;

	assign Cout_output = Cout;
	assign Sum_output = Sum;
	assign Cout_t_output = Cout_t;
	assign Sum_t_output = Sum_t;

	LUT3 #(.INIT(8'b11101000)) LUT_1 (
		.I0(B),
		.I1(A),
		.I2(Cin),
		.O(Cout)
	);

	LUT_e8 LUT_1_t(
		.I0(B),
		.I1(A),
		.I2(Cin),
		.O_t(Cout_t)
	);

	LUT3 #(.INIT(8'b10010110)) LUT_2 (
		.I0(B),
		.I1(A),
		.I2(Cin),
		.O(Sum)
	);

	LUT_96 LUT_2_t(
		.I0(B),
		.I1(A),
		.I2(Cin),
		.O_t(Sum_t)
	);


`ifdef FORMAL
	always @(*) begin
		`ifdef TAINT_A
			assume (A_t == 1'b1);
			assume (B_t == 1'b0);
			assume (Cin_t == 1'b0);
		`endif
		`ifdef TAINT_B
			assume (B_t == 1'b1);
			assume (A_t == 1'b0);
			assume (Cin_t == 1'b0);
		`endif
		`ifdef TAINT_Cin
			assume (Cin_t == 1'b1);
			assume (A_t == 1'b0);
			assume (B_t == 1'b0);
		`endif

		// Isolated Output Assertions
		`ifdef CHECK_Cout
			assert (Cout_t == 1'b0);
		`endif
		`ifdef CHECK_Sum
			assert (Sum_t == 1'b0);
		`endif
	end
`endif

endmodule

