module LUT4 #(parameter INIT = 16'b0) (
    input I0, I1, I2, I3,
    output O
);
    wire [3:0] idx = {I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_7888(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I6 & I3) 
		| (I4 & I1) 
		| (I5 & I0) 
		| (I2 & I7) 
		| (I4 & I5) 
		| (I6 & I7);

endmodule


//================================================================================

module LUT3 #(parameter INIT = 8'b0) (
    input I0, I1, I2,
    output O
);
    wire [2:0] idx = {I2, I1, I0};
    assign O = INIT[idx];
endmodule

//================================================================================

module LUT_96(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I4 | I3 | I5;

endmodule


//================================================================================

module LUT_28(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I3 & I2) 
		| (I3 & I5) 
		| (I4 & I5) 
		| (I4 & I2) 
		| (~I1 & I5 & I0) 
		| (I1 & I5 & ~I0);

endmodule


//================================================================================

module LUT_6996(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I4 | I6 | I5 | I7;

endmodule


//================================================================================

module LUT_80(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & I3 & I2) 
		| (I4 & I5 & I0) 
		| (I4 & I3 & I5) 
		| (I1 & I5 & I0) 
		| (I1 & I3 & I2) 
		| (I4 & I2 & I0) 
		| (I1 & I3 & I5);

endmodule


//================================================================================

module LUT_99f(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (~I1 & I6 & I0) 
		| (I4 & I6) 
		| (~I1 & I7 & I0) 
		| (I3 & ~I2 & I5 & ~I0) 
		| (I1 & I7 & ~I0) 
		| (I1 & I6 & ~I0) 
		| (I4 & ~I1 & ~I3 & I2) 
		| (I4 & I1 & ~I3 & ~I2) 
		| (I4 & ~I1 & I3 & ~I2) 
		| (I4 & I7) 
		| (I4 & I5) 
		| (I4 & I1 & I3 & I2) 
		| (I5 & I7) 
		| (~I3 & ~I2 & I5 & I0) 
		| (I6 & I5) 
		| (I3 & I2 & I5 & I0) 
		| (~I3 & I2 & I5 & ~I0);

endmodule


//================================================================================

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

	assign O_t = (I3 & I2) 
		| (I3 & I0) 
		| (I1 & I2);

endmodule


//================================================================================

module LUT_8000(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I4 & I2 & I5 & I7) 
		| (I2 & I5 & I7 & I0) 
		| (I6 & I3 & I5 & I0) 
		| (I1 & I6 & I3 & I0) 
		| (I1 & I6 & I7 & I0) 
		| (I4 & I1 & I6 & I7) 
		| (I4 & I6 & I3 & I5) 
		| (I4 & I6 & I5 & I7) 
		| (I4 & I1 & I6 & I3) 
		| (I6 & I5 & I7 & I0) 
		| (I4 & I1 & I3 & I2) 
		| (I4 & I3 & I2 & I5) 
		| (I4 & I1 & I2 & I7) 
		| (I1 & I2 & I7 & I0) 
		| (I3 & I2 & I5 & I0);

endmodule


//================================================================================

module LUT_17(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & ~I2 & I0) 
		| (I3 & I5) 
		| (I4 & I2 & ~I0) 
		| (I4 & I5) 
		| (~I1 & I3 & I2) 
		| (I4 & I3) 
		| (~I1 & I5 & I0) 
		| (I1 & I5 & ~I0) 
		| (I1 & I3 & ~I2);

endmodule


//================================================================================

module LUT_69(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I4 | I3 | I5;

endmodule


//================================================================================

module LUT_9666(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I6 & I7 &  
		| (I4 & I1) 
		| (I5 & I0) 
		| (I4 & I5);

endmodule


//================================================================================

module LUT_566a(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I7 &  
		| (~I1 & I6 & I0) 
		| (I4 & ~I1 & I2) 
		| (I4 & I1 & ~I2) 
		| (I4 & I6) 
		| (I2 & I5 & ~I0) 
		| (I1 & I6 & ~I0) 
		| (~I2 & I5 & I0) 
		| (I4 & I5) 
		| (I6 & I5);

endmodule


//================================================================================

module LUT_6(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & ~I0) 
		| (I3 & I5) 
		| (~I1 & I3 & I2) 
		| (I4 & I3) 
		| (I1 & I3 & ~I2) 
		| (I5 & ~I0);

endmodule


//================================================================================

module LUT_15(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & ~I2 & I0) 
		| (~I1 & I5) 
		| (I3 & I5) 
		| (I4 & I5) 
		| (I1 & I3 & ~I2) 
		| (I4 & I3 & ~I2) 
		| (I5 & ~I0);

endmodule


//================================================================================

module LUT_8e(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & ~I2 & ~I0) 
		| (I3 & I5) 
		| (I4 & I5) 
		| (~I1 & I3 & I2) 
		| (I4 & I3) 
		| (~I1 & I5 & ~I0) 
		| (I1 & I5 & I0) 
		| (I1 & I3 & ~I2) 
		| (I4 & I2 & I0);

endmodule


//================================================================================

module LUT_56(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I5 &  
		| (I4 & ~I0) 
		| (I4 & I3) 
		| (~I1 & I3);

endmodule


//================================================================================

module LUT_aa6a(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I7 &  
		| (I4 & I2 & I5) 
		| (I2 & I5 & ~I0) 
		| (I1 & I6 & ~I0) 
		| (I4 & I1 & I6) 
		| (I4 & I1 & I2) 
		| (I4 & I6 & I5) 
		| (I6 & I5 & ~I0);

endmodule


//================================================================================

module LUT_a880(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I1 & I6 & I3 & ~I0) 
		| (I4 & I6 & I3) 
		| (I6 & I7 & I0) 
		| (I4 & I3 & I5) 
		| (~I1 & I6 & I3 & I0) 
		| (I6 & I3 & I5) 
		| (I1 & I6 & I7) 
		| (I4 & ~I1 & I3 & I2) 
		| (I2 & I5 & I7) 
		| (I4 & I2 & I7) 
		| (I4 & I5 & I7) 
		| (I5 & I7 & I0) 
		| (I1 & I7 & I0) 
		| (I3 & ~I2 & I5 & I0) 
		| (I1 & I2 & I7) 
		| (I4 & I1 & I7) 
		| (I4 & I1 & I3 & ~I2) 
		| (I6 & I5 & I7) 
		| (I3 & I2 & I5 & ~I0) 
		| (I2 & I7 & I0) 
		| (I4 & I6 & I7);

endmodule


//================================================================================

module LUT_888(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I6 & I3 & ~I0) 
		| (I4 & I6 & I3) 
		| (I6 & I5 & I7) 
		| (~I1 & I6 & I7) 
		| (~I1 & I2 & I7) 
		| (I6 & I7 & ~I0) 
		| (~I1 & I6 & I3) 
		| (I2 & I5 & I7) 
		| (I4 & I2 & I7) 
		| (I4 & I1 & I3 & I2) 
		| (I4 & I3 & I2 & I5) 
		| (I4 & I6 & I7) 
		| (I2 & I7 & ~I0) 
		| (I3 & I2 & I5 & I0) 
		| (I6 & I3 & I5);

endmodule


//================================================================================

module LUT_ddd5(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I6 & I3 & I0) 
		| (I4 & I6 & I3) 
		| (I3 & I2 & I5 & ~I0) 
		| (~I2 & I7) 
		| (I4 & ~I1 & I3 & I2) 
		| (~I1 & I7 & ~I0) 
		| (I5 & I7 & ~I0) 
		| (I4 & ~I1 & I7) 
		| (I4 & I3 & I2 & I5) 
		| (I1 & I6 & I3) 
		| (I4 & I5 & I7) 
		| (I6 & I7) 
		| (I6 & I3 & I5);

endmodule


//================================================================================

module LUT_777f(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I6 & I3 & I0) 
		| (I4 & I6 & I3) 
		| (I6 & I5 & I7) 
		| (I1 & I6 & I7) 
		| (I3 & I2 & I5 & ~I0) 
		| (I6 & I7 & I0) 
		| (I4 & ~I1 & I3 & I2) 
		| (I2 & I7 & I0) 
		| (I1 & I2 & I7) 
		| (I2 & I5 & I7) 
		| (I4 & I2 & I7) 
		| (I4 & I3 & I2 & I5) 
		| (I1 & I6 & I3) 
		| (I4 & I6 & I7) 
		| (I6 & I3 & I5);

endmodule


//================================================================================

module mult(
	input a0, a1, a2, a3, b0, b1, b2, b3, a0_t, a1_t, a2_t, a3_t, b0_t, b1_t, b2_t, b3_t, 
	output result0, result1, result2, result3, result4, result5, result6, result7, result0_t, result1_t, result2_t, result3_t, result4_t, result5_t, result6_t, result7_t
);

	LUT4 #(.INIT(16'b0111100010001000)) LUT_1 (
		.I0(a1),
		.I1(b0),
		.I2(b1),
		.I3(a0),
		.O(result1)
	);

	LUT_7888 LUT_1_t(
		.I0(a1),
		.I1(b0),
		.I2(b1),
		.I3(a0),
		.I4(a1_t),
		.I5(b0_t),
		.I6(b1_t),
		.I7(a0_t),
		.O_t(result1_t)
	);

	LUT3 #(.INIT(8'b10010110)) LUT_2 (
		.I0(result_$lut_Y_1_A_2),
		.I1(result_$lut_Y_1_A_1),
		.I2(result_$lut_Y_1_A),
		.O(result3)
	);

	LUT_96 LUT_2_t(
		.I0(result_$lut_Y_1_A_2),
		.I1(result_$lut_Y_1_A_1),
		.I2(result_$lut_Y_1_A),
		.I3(result_$lut_Y_1_A_2_t),
		.I4(result_$lut_Y_1_A_1_t),
		.I5(result_$lut_Y_1_A_t),
		.O_t(result3_t)
	);

	LUT3 #(.INIT(8'b00101000)) LUT_3 (
		.I0(a2),
		.I1(result_$lut_Y_3_A_1),
		.I2(result_$lut_Y_3_A),
		.O(result_$lut_Y_1_A)
	);

	LUT_28 LUT_3_t(
		.I0(a2),
		.I1(result_$lut_Y_3_A_1),
		.I2(result_$lut_Y_3_A),
		.I3(a2_t),
		.I4(result_$lut_Y_3_A_1_t),
		.I5(result_$lut_Y_3_A_t),
		.O_t(result_$lut_Y_1_A_t)
	);

	LUT4 #(.INIT(16'b0110100110010110)) LUT_4 (
		.I0(result_$lut_Y_2_A_$lut_Y_A_3),
		.I1(result_$lut_Y_2_A_$lut_Y_A_2),
		.I2(result_$lut_Y_2_A_$lut_Y_A_1),
		.I3(result_$lut_Y_2_A_$lut_Y_A),
		.O(result_$lut_Y_1_A_1)
	);

	LUT_6996 LUT_4_t(
		.I0(result_$lut_Y_2_A_$lut_Y_A_3),
		.I1(result_$lut_Y_2_A_$lut_Y_A_2),
		.I2(result_$lut_Y_2_A_$lut_Y_A_1),
		.I3(result_$lut_Y_2_A_$lut_Y_A),
		.I4(result_$lut_Y_2_A_$lut_Y_A_3_t),
		.I5(result_$lut_Y_2_A_$lut_Y_A_2_t),
		.I6(result_$lut_Y_2_A_$lut_Y_A_1_t),
		.I7(result_$lut_Y_2_A_$lut_Y_A_t),
		.O_t(result_$lut_Y_1_A_1_t)
	);

	LUT3 #(.INIT(8'b10000000)) LUT_5 (
		.I0(result_$lut_Y_3_A_1),
		.I1(a2),
		.I2(b0),
		.O(result_$lut_Y_1_A_2)
	);

	LUT_80 LUT_5_t(
		.I0(result_$lut_Y_3_A_1),
		.I1(a2),
		.I2(b0),
		.I3(result_$lut_Y_3_A_1_t),
		.I4(a2_t),
		.I5(b0_t),
		.O_t(result_$lut_Y_1_A_2_t)
	);

	LUT3 #(.INIT(8'b10010110)) LUT_6 (
		.I0(result_$lut_Y_2_A_2),
		.I1(result_$lut_Y_2_A_1),
		.I2(result_$lut_Y_2_A),
		.O(result4)
	);

	LUT_96 LUT_6_t(
		.I0(result_$lut_Y_2_A_2),
		.I1(result_$lut_Y_2_A_1),
		.I2(result_$lut_Y_2_A),
		.I3(result_$lut_Y_2_A_2_t),
		.I4(result_$lut_Y_2_A_1_t),
		.I5(result_$lut_Y_2_A_t),
		.O_t(result4_t)
	);

	LUT4 #(.INIT(16'b0000100110011111)) LUT_7 (
		.I0(result_$lut_Y_2_A_$lut_Y_A_1),
		.I1(result_$lut_Y_2_A_$lut_Y_A),
		.I2(result_$lut_Y_2_A_$lut_Y_A_3),
		.I3(result_$lut_Y_2_A_$lut_Y_A_2),
		.O(result_$lut_Y_2_A)
	);

	LUT_99f LUT_7_t(
		.I0(result_$lut_Y_2_A_$lut_Y_A_1),
		.I1(result_$lut_Y_2_A_$lut_Y_A),
		.I2(result_$lut_Y_2_A_$lut_Y_A_3),
		.I3(result_$lut_Y_2_A_$lut_Y_A_2),
		.I4(result_$lut_Y_2_A_$lut_Y_A_1_t),
		.I5(result_$lut_Y_2_A_$lut_Y_A_t),
		.I6(result_$lut_Y_2_A_$lut_Y_A_3_t),
		.I7(result_$lut_Y_2_A_$lut_Y_A_2_t),
		.O_t(result_$lut_Y_2_A_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_8 (
		.I0(a3),
		.I1(b0),
		.O(result_$lut_Y_2_A_$lut_Y_A)
	);

	LUT_8 LUT_8_t(
		.I0(a3),
		.I1(b0),
		.I2(a3_t),
		.I3(b0_t),
		.O_t(result_$lut_Y_2_A_$lut_Y_A_t)
	);

	LUT4 #(.INIT(16'b1000000000000000)) LUT_9 (
		.I0(b2),
		.I1(a1),
		.I2(b1),
		.I3(a0),
		.O(result_$lut_Y_2_A_$lut_Y_A_1)
	);

	LUT_8000 LUT_9_t(
		.I0(b2),
		.I1(a1),
		.I2(b1),
		.I3(a0),
		.I4(b2_t),
		.I5(a1_t),
		.I6(b1_t),
		.I7(a0_t),
		.O_t(result_$lut_Y_2_A_$lut_Y_A_1_t)
	);

	LUT4 #(.INIT(16'b0111100010001000)) LUT_10 (
		.I0(b2),
		.I1(a1),
		.I2(b3),
		.I3(a0),
		.O(result_$lut_Y_2_A_$lut_Y_A_2)
	);

	LUT_7888 LUT_10_t(
		.I0(b2),
		.I1(a1),
		.I2(b3),
		.I3(a0),
		.I4(b2_t),
		.I5(a1_t),
		.I6(b3_t),
		.I7(a0_t),
		.O_t(result_$lut_Y_2_A_$lut_Y_A_2_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_11 (
		.I0(a2),
		.I1(b1),
		.O(result_$lut_Y_2_A_$lut_Y_A_3)
	);

	LUT_8 LUT_11_t(
		.I0(a2),
		.I1(b1),
		.I2(a2_t),
		.I3(b1_t),
		.O_t(result_$lut_Y_2_A_$lut_Y_A_3_t)
	);

	LUT3 #(.INIT(8'b00010111)) LUT_12 (
		.I0(result_$lut_Y_1_A_2),
		.I1(result_$lut_Y_1_A_1),
		.I2(result_$lut_Y_1_A),
		.O(result_$lut_Y_2_A_1)
	);

	LUT_17 LUT_12_t(
		.I0(result_$lut_Y_1_A_2),
		.I1(result_$lut_Y_1_A_1),
		.I2(result_$lut_Y_1_A),
		.I3(result_$lut_Y_1_A_2_t),
		.I4(result_$lut_Y_1_A_1_t),
		.I5(result_$lut_Y_1_A_t),
		.O_t(result_$lut_Y_2_A_1_t)
	);

	LUT3 #(.INIT(8'b01101001)) LUT_13 (
		.I0(result_$lut_Y_4_A_1_$lut_Y_A),
		.I1(result_$lut_Y_4_A_1_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.O(result_$lut_Y_2_A_2)
	);

	LUT_69 LUT_13_t(
		.I0(result_$lut_Y_4_A_1_$lut_Y_A),
		.I1(result_$lut_Y_4_A_1_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_1_$lut_Y_A_t),
		.I4(result_$lut_Y_4_A_1_$lut_Y_A_1_t),
		.I5(result_$lut_Y_4_A_$lut_Y_A_2_t),
		.O_t(result_$lut_Y_2_A_2_t)
	);

	LUT4 #(.INIT(16'b1001011001100110)) LUT_14 (
		.I0(a2),
		.I1(b0),
		.I2(result_$lut_Y_3_A_1),
		.I3(result_$lut_Y_3_A),
		.O(result2)
	);

	LUT_9666 LUT_14_t(
		.I0(a2),
		.I1(b0),
		.I2(result_$lut_Y_3_A_1),
		.I3(result_$lut_Y_3_A),
		.I4(a2_t),
		.I5(b0_t),
		.I6(result_$lut_Y_3_A_1_t),
		.I7(result_$lut_Y_3_A_t),
		.O_t(result2_t)
	);

	LUT4 #(.INIT(16'b1000000000000000)) LUT_15 (
		.I0(a1),
		.I1(b1),
		.I2(a0),
		.I3(b0),
		.O(result_$lut_Y_3_A)
	);

	LUT_8000 LUT_15_t(
		.I0(a1),
		.I1(b1),
		.I2(a0),
		.I3(b0),
		.I4(a1_t),
		.I5(b1_t),
		.I6(a0_t),
		.I7(b0_t),
		.O_t(result_$lut_Y_3_A_t)
	);

	LUT4 #(.INIT(16'b0111100010001000)) LUT_16 (
		.I0(b2),
		.I1(a0),
		.I2(a1),
		.I3(b1),
		.O(result_$lut_Y_3_A_1)
	);

	LUT_7888 LUT_16_t(
		.I0(b2),
		.I1(a0),
		.I2(a1),
		.I3(b1),
		.I4(b2_t),
		.I5(a0_t),
		.I6(a1_t),
		.I7(b1_t),
		.O_t(result_$lut_Y_3_A_1_t)
	);

	LUT3 #(.INIT(8'b01101001)) LUT_17 (
		.I0(result_$lut_Y_4_A_2),
		.I1(result_$lut_Y_4_A_1),
		.I2(result_$lut_Y_4_A),
		.O(result5)
	);

	LUT_69 LUT_17_t(
		.I0(result_$lut_Y_4_A_2),
		.I1(result_$lut_Y_4_A_1),
		.I2(result_$lut_Y_4_A),
		.I3(result_$lut_Y_4_A_2_t),
		.I4(result_$lut_Y_4_A_1_t),
		.I5(result_$lut_Y_4_A_t),
		.O_t(result5_t)
	);

	LUT4 #(.INIT(16'b0101011001101010)) LUT_18 (
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_$lut_Y_A),
		.O(result_$lut_Y_4_A)
	);

	LUT_566a LUT_18_t(
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_$lut_Y_A),
		.I4(result_$lut_Y_5_A_$lut_Y_A_1_t),
		.I5(result_$lut_Y_4_A_$lut_Y_A_1_t),
		.I6(result_$lut_Y_4_A_$lut_Y_A_2_t),
		.I7(result_$lut_Y_4_A_$lut_Y_A_t),
		.O_t(result_$lut_Y_4_A_t)
	);

	LUT4 #(.INIT(16'b0111100010001000)) LUT_19 (
		.I0(a2),
		.I1(b3),
		.I2(b2),
		.I3(a3),
		.O(result_$lut_Y_4_A_$lut_Y_A)
	);

	LUT_7888 LUT_19_t(
		.I0(a2),
		.I1(b3),
		.I2(b2),
		.I3(a3),
		.I4(a2_t),
		.I5(b3_t),
		.I6(b2_t),
		.I7(a3_t),
		.O_t(result_$lut_Y_4_A_$lut_Y_A_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_20 (
		.I0(a1),
		.I1(b3),
		.O(result_$lut_Y_4_A_$lut_Y_A_1)
	);

	LUT_8 LUT_20_t(
		.I0(a1),
		.I1(b3),
		.I2(a1_t),
		.I3(b3_t),
		.O_t(result_$lut_Y_4_A_$lut_Y_A_1_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_21 (
		.I0(a3),
		.I1(b1),
		.O(result_$lut_Y_4_A_$lut_Y_A_2)
	);

	LUT_8 LUT_21_t(
		.I0(a3),
		.I1(b1),
		.I2(a3_t),
		.I3(b1_t),
		.O_t(result_$lut_Y_4_A_$lut_Y_A_2_t)
	);

	LUT3 #(.INIT(8'b00000110)) LUT_22 (
		.I0(result_$lut_Y_4_A_1_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_1_$lut_Y_A),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.O(result_$lut_Y_4_A_1)
	);

	LUT_6 LUT_22_t(
		.I0(result_$lut_Y_4_A_1_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_1_$lut_Y_A),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_1_$lut_Y_A_1_t),
		.I4(result_$lut_Y_4_A_1_$lut_Y_A_t),
		.I5(result_$lut_Y_4_A_$lut_Y_A_2_t),
		.O_t(result_$lut_Y_4_A_1_t)
	);

	LUT2 #(.INIT(4'b0110)) LUT_23 (
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.O(result_$lut_Y_4_A_1_$lut_Y_A)
	);

	LUT_6 LUT_23_t(
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.I2(result_$lut_Y_5_A_$lut_Y_A_1_t),
		.I3(result_$lut_Y_4_A_$lut_Y_A_1_t),
		.O_t(result_$lut_Y_4_A_1_$lut_Y_A_t)
	);

	LUT3 #(.INIT(8'b00010101)) LUT_24 (
		.I0(result_$lut_Y_2_A_$lut_Y_A_2),
		.I1(result_$lut_Y_2_A_$lut_Y_A_3),
		.I2(result_$lut_Y_4_A_1_$lut_Y_A_1_$lut_Y_A),
		.O(result_$lut_Y_4_A_1_$lut_Y_A_1)
	);

	LUT_15 LUT_24_t(
		.I0(result_$lut_Y_2_A_$lut_Y_A_2),
		.I1(result_$lut_Y_2_A_$lut_Y_A_3),
		.I2(result_$lut_Y_4_A_1_$lut_Y_A_1_$lut_Y_A),
		.I3(result_$lut_Y_2_A_$lut_Y_A_2_t),
		.I4(result_$lut_Y_2_A_$lut_Y_A_3_t),
		.I5(result_$lut_Y_4_A_1_$lut_Y_A_1_$lut_Y_A_t),
		.O_t(result_$lut_Y_4_A_1_$lut_Y_A_1_t)
	);

	LUT4 #(.INIT(16'b1000000000000000)) LUT_25 (
		.I0(b2),
		.I1(a1),
		.I2(b3),
		.I3(a0),
		.O(result_$lut_Y_4_A_1_$lut_Y_A_1_$lut_Y_A)
	);

	LUT_8000 LUT_25_t(
		.I0(b2),
		.I1(a1),
		.I2(b3),
		.I3(a0),
		.I4(b2_t),
		.I5(a1_t),
		.I6(b3_t),
		.I7(a0_t),
		.O_t(result_$lut_Y_4_A_1_$lut_Y_A_1_$lut_Y_A_t)
	);

	LUT3 #(.INIT(8'b10001110)) LUT_26 (
		.I0(result_$lut_Y_2_A_2),
		.I1(result_$lut_Y_2_A_1),
		.I2(result_$lut_Y_2_A),
		.O(result_$lut_Y_4_A_2)
	);

	LUT_8e LUT_26_t(
		.I0(result_$lut_Y_2_A_2),
		.I1(result_$lut_Y_2_A_1),
		.I2(result_$lut_Y_2_A),
		.I3(result_$lut_Y_2_A_2_t),
		.I4(result_$lut_Y_2_A_1_t),
		.I5(result_$lut_Y_2_A_t),
		.O_t(result_$lut_Y_4_A_2_t)
	);

	LUT3 #(.INIT(8'b01010110)) LUT_27 (
		.I0(result_$lut_Y_5_A_2),
		.I1(result_$lut_Y_5_A_1),
		.I2(result_$lut_Y_5_A),
		.O(result6)
	);

	LUT_56 LUT_27_t(
		.I0(result_$lut_Y_5_A_2),
		.I1(result_$lut_Y_5_A_1),
		.I2(result_$lut_Y_5_A),
		.I3(result_$lut_Y_5_A_2_t),
		.I4(result_$lut_Y_5_A_1_t),
		.I5(result_$lut_Y_5_A_t),
		.O_t(result6_t)
	);

	LUT4 #(.INIT(16'b1010101001101010)) LUT_28 (
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(b3),
		.I2(a3),
		.I3(result_$lut_Y_5_A_$lut_Y_A),
		.O(result_$lut_Y_5_A)
	);

	LUT_aa6a LUT_28_t(
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(b3),
		.I2(a3),
		.I3(result_$lut_Y_5_A_$lut_Y_A),
		.I4(result_$lut_Y_5_A_$lut_Y_A_1_t),
		.I5(b3_t),
		.I6(a3_t),
		.I7(result_$lut_Y_5_A_$lut_Y_A_t),
		.O_t(result_$lut_Y_5_A_t)
	);

	LUT4 #(.INIT(16'b1010100010000000)) LUT_29 (
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_$lut_Y_A),
		.O(result_$lut_Y_5_A_$lut_Y_A)
	);

	LUT_a880 LUT_29_t(
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_4_A_$lut_Y_A_1),
		.I2(result_$lut_Y_4_A_$lut_Y_A_2),
		.I3(result_$lut_Y_4_A_$lut_Y_A),
		.I4(result_$lut_Y_5_A_$lut_Y_A_1_t),
		.I5(result_$lut_Y_4_A_$lut_Y_A_1_t),
		.I6(result_$lut_Y_4_A_$lut_Y_A_2_t),
		.I7(result_$lut_Y_4_A_$lut_Y_A_t),
		.O_t(result_$lut_Y_5_A_$lut_Y_A_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_30 (
		.I0(a2),
		.I1(b2),
		.O(result_$lut_Y_5_A_$lut_Y_A_1)
	);

	LUT_8 LUT_30_t(
		.I0(a2),
		.I1(b2),
		.I2(a2_t),
		.I3(b2_t),
		.O_t(result_$lut_Y_5_A_$lut_Y_A_1_t)
	);

	LUT4 #(.INIT(16'b0000100010001000)) LUT_31 (
		.I0(result_$lut_Y_2_A_1),
		.I1(result_$lut_Y_2_A),
		.I2(result_$lut_Y_2_A_2),
		.I3(result_$lut_Y_4_A),
		.O(result_$lut_Y_5_A_1)
	);

	LUT_888 LUT_31_t(
		.I0(result_$lut_Y_2_A_1),
		.I1(result_$lut_Y_2_A),
		.I2(result_$lut_Y_2_A_2),
		.I3(result_$lut_Y_4_A),
		.I4(result_$lut_Y_2_A_1_t),
		.I5(result_$lut_Y_2_A_t),
		.I6(result_$lut_Y_2_A_2_t),
		.I7(result_$lut_Y_4_A_t),
		.O_t(result_$lut_Y_5_A_1_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_32 (
		.I0(result_$lut_Y_4_A_1),
		.I1(result_$lut_Y_4_A),
		.O(result_$lut_Y_5_A_2)
	);

	LUT_8 LUT_32_t(
		.I0(result_$lut_Y_4_A_1),
		.I1(result_$lut_Y_4_A),
		.I2(result_$lut_Y_4_A_1_t),
		.I3(result_$lut_Y_4_A_t),
		.O_t(result_$lut_Y_5_A_2_t)
	);

	LUT4 #(.INIT(16'b1101110111010101)) LUT_33 (
		.I0(result_$lut_Y_5_A_1),
		.I1(result_$lut_Y_5_A_2),
		.I2(result_$lut_Y_5_A),
		.I3(result_$lut_Y_6_A),
		.O(result7)
	);

	LUT_ddd5 LUT_33_t(
		.I0(result_$lut_Y_5_A_1),
		.I1(result_$lut_Y_5_A_2),
		.I2(result_$lut_Y_5_A),
		.I3(result_$lut_Y_6_A),
		.I4(result_$lut_Y_5_A_1_t),
		.I5(result_$lut_Y_5_A_2_t),
		.I6(result_$lut_Y_5_A_t),
		.I7(result_$lut_Y_6_A_t),
		.O_t(result7_t)
	);

	LUT4 #(.INIT(16'b0111011101111111)) LUT_34 (
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_5_A_$lut_Y_A),
		.I2(b3),
		.I3(a3),
		.O(result_$lut_Y_6_A)
	);

	LUT_777f LUT_34_t(
		.I0(result_$lut_Y_5_A_$lut_Y_A_1),
		.I1(result_$lut_Y_5_A_$lut_Y_A),
		.I2(b3),
		.I3(a3),
		.I4(result_$lut_Y_5_A_$lut_Y_A_1_t),
		.I5(result_$lut_Y_5_A_$lut_Y_A_t),
		.I6(b3_t),
		.I7(a3_t),
		.O_t(result_$lut_Y_6_A_t)
	);

	LUT2 #(.INIT(4'b1000)) LUT_35 (
		.I0(a0),
		.I1(b0),
		.O(result0)
	);

	LUT_8 LUT_35_t(
		.I0(a0),
		.I1(b0),
		.I2(a0_t),
		.I3(b0_t),
		.O_t(result0_t)
	);


`ifdef FORMAL
	always @(*) begin
		`ifdef TAINT_a0
			assume (a0_t == 1'b1);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_a1
			assume (a1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_a2
			assume (a2_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_a3
			assume (a3_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_b0
			assume (b0_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_b1
			assume (b1_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b2_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_b2
			assume (b2_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b3_t == 1'b0);
		`endif
		`ifdef TAINT_b3
			assume (b3_t == 1'b1);
			assume (a0_t == 1'b0);
			assume (a1_t == 1'b0);
			assume (a2_t == 1'b0);
			assume (a3_t == 1'b0);
			assume (b0_t == 1'b0);
			assume (b1_t == 1'b0);
			assume (b2_t == 1'b0);
		`endif

		// Isolated Output Assertions
		`ifdef CHECK_result0
			assert (result0_t == 1'b0);
		`endif
		`ifdef CHECK_result1
			assert (result1_t == 1'b0);
		`endif
		`ifdef CHECK_result2
			assert (result2_t == 1'b0);
		`endif
		`ifdef CHECK_result3
			assert (result3_t == 1'b0);
		`endif
		`ifdef CHECK_result4
			assert (result4_t == 1'b0);
		`endif
		`ifdef CHECK_result5
			assert (result5_t == 1'b0);
		`endif
		`ifdef CHECK_result6
			assert (result6_t == 1'b0);
		`endif
		`ifdef CHECK_result7
			assert (result7_t == 1'b0);
		`endif
	end
`endif

endmodule

