module LUT_e8(
	input I0, I1, I2, I3, I4, I5, 
	output O, O_t
);

	assign O = (I1 & I2) 
		| (I0 & I2) 
		| (I1 & I0);

	assign O_t = (I0 & I4 & ~I2) 
		| (I3 & I5) 
		| (~I0 & I4 & I2) 
		| (I5 & I4) 
		| (I3 & ~I1 & I2) 
		| (I3 & I4) 
		| (~I1 & I5 & I0) 
		| (I1 & I5 & ~I0) 
		| (I3 & I1 & ~I2);

endmodule


//================================================================================

