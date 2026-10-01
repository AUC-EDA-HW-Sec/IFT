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
