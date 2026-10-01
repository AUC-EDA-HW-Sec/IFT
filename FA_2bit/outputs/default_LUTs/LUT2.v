module LUT2 #(parameter INIT = 4'b0) (
    input I0, I1,
    output O
);
    wire [1:0] idx = {I1, I0};
    assign O = INIT[idx];
endmodule