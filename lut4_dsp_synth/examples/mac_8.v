// Example 2 -- multiply-accumulate: DSP plus soft logic in one design.
//
// The multiply must land on mult_8; the 16-bit add has no hard block to go to
// and must become LUT4 soft logic. This is the case that shows the flow does
// not simply preserve everything or lower everything -- it splits the design
// across the two resource types.
//
// Same functional shape as OpenFPGA's own micro_benchmark/mac/mac_8.

module mac_8 (
  input  [7:0]  a,
  input  [7:0]  b,
  input  [15:0] c,
  output [15:0] p
);
  assign p = a * b + c;
endmodule
