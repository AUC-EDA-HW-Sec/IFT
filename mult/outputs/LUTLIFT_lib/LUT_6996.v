module LUT_6996(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I4 | I6 | I5 | I7;

endmodule
