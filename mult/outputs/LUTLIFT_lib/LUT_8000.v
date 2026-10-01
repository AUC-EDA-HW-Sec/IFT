module LUT_8000(
	input I0, I1, I2, I3, I4, I5, I6, I7, 
	output O_t
);

	assign O_t = (I4 & I2 & I5 & I7) 
		| (I2 & I5 & I7 & I0) 
		| (I6 & I3 & I5 & I0) 
		| (I1 & I6 & I3 & I0) 
		| (I1 & I6 & I7 & I0) 
		| (I4 & I1 & I6 & I7) 
		| (I4 & I6 & I3 & I5) 
		| (I4 & I6 & I5 & I7) 
		| (I4 & I1 & I6 & I3) 
		| (I6 & I5 & I7 & I0) 
		| (I4 & I1 & I3 & I2) 
		| (I4 & I3 & I2 & I5) 
		| (I4 & I1 & I2 & I7) 
		| (I1 & I2 & I7 & I0) 
		| (I3 & I2 & I5 & I0);

endmodule
