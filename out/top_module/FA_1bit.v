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

	assign O_t = (I4 & ~I2 & I0) 
		| (I3 & I5) 
		| (I4 & I2 & ~I0) 
		| (I4 & I5) 
		| (I3 & ~I1 & I2) 
		| (I3 & I4) 
		| (I5 & ~I1 & I0) 
		| (I5 & I1 & ~I0) 
		| (I3 & I1 & ~I2);

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

		// Global Assertions: Taint must never reach any primary output
		assert (Cout_t == 1'b0);
		assert (Sum_t == 1'b0);
	end
`endif

endmodule

