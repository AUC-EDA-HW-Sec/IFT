module LUT3 #(parameter INIT = 8'b0) (
    input I0, I1, I2,
    output O
);
    wire [2:0] idx = {I2, I1, I0};
    assign O = INIT[idx];
endmodule