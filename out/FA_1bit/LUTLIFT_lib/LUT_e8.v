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
