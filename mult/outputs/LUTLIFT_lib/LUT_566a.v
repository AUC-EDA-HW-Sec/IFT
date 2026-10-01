module LUT_566a(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = I7 &  
		| (~I1 & I6 & I0) 
		| (I4 & ~I1 & I2) 
		| (I4 & I1 & ~I2) 
		| (I4 & I6) 
		| (I2 & I5 & ~I0) 
		| (I1 & I6 & ~I0) 
		| (~I2 & I5 & I0) 
		| (I4 & I5) 
		| (I6 & I5);

endmodule
