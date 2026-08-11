// Example 4 -- a DSP the RTL INSTANTIATES rather than infers.
//
// This is the second, distinct preservation path. There is no `*` here for
// mul2dsp to find; the design names mult_8 itself. What has to hold is that
// `flatten` does not inline the instance and abc does not grind it up -- which
// is exactly what `read_verilog -lib` buys, and nothing else in the script.
//
// MEASURED, because the plausible guess is wrong: dropping the `-lib` does NOT
// quietly produce a LUT-only netlist. It fails loudly, at `hierarchy -check`,
// with
//   ERROR: Module `\mult_8' referenced in module `\mult_direct_inst' ...
//          is not part of the design
// because `flatten` inlines the instance, the now-unused mult_8 module is
// dropped, and the DSP mapping in step 3 then re-creates a reference to it.
// Tried both ways -- the whole library read without `-lib`, and mult_8 alone
// given a body while lut4 stayed a blackbox -- and both give that same error.
// So Yosys, not the cell-count assertion, is what guards this particular
// mistake. The assertion earns its place elsewhere: see mult_signed_8x8.v,
// which produces zero DSPs and still passes 65536 exhaustive vectors.
//
// On mult_8's OpenFPGA-style descending ports (A is [0:7], Y is [0:15]): a
// vector port connection aligns leftmost-bit to leftmost-bit, so `.A(a)` with
// `a` declared [7:0] maps a[7] onto A[0]. Both are the MSB, so the arithmetic
// is right and no bit reversal is needed. It only looks alarming.

module mult_direct_inst (
  input  [7:0]  a,
  input  [7:0]  b,
  input  [15:0] mask,
  output [15:0] p
);
  wire [15:0] prod;

  mult_8 u_mul (
    .A (a),
    .B (b),
    .Y (prod)
  );

  // A little soft logic downstream, so the design is not purely one cell.
  assign p = prod ^ mask;
endmodule
