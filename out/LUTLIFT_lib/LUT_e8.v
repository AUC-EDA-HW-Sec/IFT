module LUT_e8(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = (I4 & ~I2 & I0) 
		| (I3 & I5) 
		| (I4 & I2 & ~I0) 
		| (I5 & I4) 
		| (I3 & ~I1 & I2) 
		| (I3 & I4) 
		| (~I1 & I5 & I0) 
		| (I1 & I5 & ~I0) 
		| (I3 & I1 & ~I2);

endmodule
