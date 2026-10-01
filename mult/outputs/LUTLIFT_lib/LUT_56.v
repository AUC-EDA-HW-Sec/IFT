module LUT_56(
	input I0, I1, I2, I3, I4, I5, 
	output O_t
);

	assign O_t = I5 &  
		| (I4 & ~I0) 
		| (I4 & I3) 
		| (~I1 & I3);

endmodule
