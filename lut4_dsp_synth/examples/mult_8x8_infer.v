// Example 1 -- the simplest possible DSP inference.
//
// An 8x8 unsigned multiply, exactly the shape of the mult_8 primitive.
// Expected: 1 mult_8, and essentially no soft logic (the product wires
// straight to the output port).

module mult_8x8_infer (
  input  [7:0]  a,
  input  [7:0]  b,
  output [15:0] p
);
  assign p = a * b;
endmodule
