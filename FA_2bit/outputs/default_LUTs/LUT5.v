module LUT5 #(parameter INIT = 32'b0) (
    input I0, I1, I2, I3, I4,
    output O
);
    wire [4:0] idx = {I4, I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule