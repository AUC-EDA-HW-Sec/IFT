module LUT_e(
	input I0, I1, I2, I3, 
	output O, O_t
);

	assign O = I0 | I1;

	assign O_t = (I2 & ~I1) 
		| (I2 & I3) 
		| (I3 & ~I0);

endmodule


//================================================================================

