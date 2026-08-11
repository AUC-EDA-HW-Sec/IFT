// Example 3 -- a multiply WIDER than the DSP primitive.
//
// A 16x16 multiply cannot fit one 8x8 block. +/mul2dsp.v decomposes it into
// four 8x8 partial products plus a shift-and-add tree, so the expected result
// is 4 x mult_8 and a substantial pile of LUT4 for the adders.
//
// This is the interesting case for the workflow: "preserve the DSP" is not
// only pass-through, it is also decomposition onto the available block.

module mult_16x16_split (
  input  [15:0] a,
  input  [15:0] b,
  output [31:0] p
);
  assign p = a * b;
endmodule
