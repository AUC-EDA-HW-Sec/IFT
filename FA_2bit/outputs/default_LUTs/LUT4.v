module LUT4 #(parameter INIT = 16'b0) (
    input I0, I1, I2, I3,
    output O
);
    wire [3:0] idx = {I3, I2, I1, I0};
    assign O = INIT[idx];
endmodule