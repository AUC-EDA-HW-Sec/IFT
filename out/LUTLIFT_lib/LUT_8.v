module LUT_8(
	input I0, I1, I2, I3, 
	output O, O_t
);

	assign O = I0 & I1;

	assign O_t = (I3 & I0) 
		| (I2 & I1) 
		| (I2 & I3);

endmodule


//================================================================================

