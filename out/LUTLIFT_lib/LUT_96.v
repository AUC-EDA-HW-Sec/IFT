module LUT_96(
	input I0, I1, I2, I3, I4, I5, 
	output O, O_t
);

	assign O = (I1 & I0 & I2) 
		| (I1 & ~I0 & ~I2) 
		| (~I1 & I0 & ~I2) 
		| (~I1 & ~I0 & I2);

	assign O_t = I3 | I5 | I4;

endmodule


//================================================================================

