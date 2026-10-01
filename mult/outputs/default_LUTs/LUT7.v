module LUT7 #(parameter INIT = 128'b0) (
    input I0, I1, I2, I3, I4, I5, I6,
    output O
);
    wire [6:0] idx = {I6, I5, I4, I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule