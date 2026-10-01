module LUT6 #(parameter INIT = 64'b0) (
    input I0, I1, I2, I3, I4, I5,
    output O
);
    wire [5:0] idx = {I5, I4, I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule