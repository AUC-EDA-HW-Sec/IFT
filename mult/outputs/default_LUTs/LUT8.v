module LUT8 #(parameter INIT = 256'b0) (
    input I0, I1, I2, I3, I4, I5, I6, I7,
    output O
);
    wire [7:0] idx = {I7, I6, I5, I4, I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule