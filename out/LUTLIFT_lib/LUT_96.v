module LUT_96(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I3 | I4 | I5;

endmodule


//================================================================================

