module FA_2bit (
    input  wire [1:0] a,
    input  wire [1:0] b,
    input  wire       cin,
    output wire [1:0] sum,
    output wire       cout
);

    assign {cout, sum} = a + b + cin;

endmodule
