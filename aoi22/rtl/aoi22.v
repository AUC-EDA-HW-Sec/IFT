module aoi22 (
    input [1:0] a, 
    input [1:0] b,
    output y
);

    wire n1, n2;
    assign n1 = ~(a[0] & a[1]);
    assign n2 = ~(b[0] & b[1]);
    assign y = ~(n1 & n2);

endmodule