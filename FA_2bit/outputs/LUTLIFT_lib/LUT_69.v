module LUT_69(
	input I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, 
	output O_t
);

	assign O_t = I3 | I4 | I5;

endmodule
