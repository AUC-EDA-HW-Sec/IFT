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
