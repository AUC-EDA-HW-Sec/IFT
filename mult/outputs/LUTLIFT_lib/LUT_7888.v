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
