module LUT_8(
	input I0, I1, I2, I3, 
	output O_t
);

	assign O_t = (I3 & I2) 
		| (I3 & I0) 
		| (I1 & I2);

endmodule
