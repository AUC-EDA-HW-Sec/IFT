// Example 8 -- NEGATIVE CONTROL: a multiply the primitive cannot express.
//
// mult_8 is unsigned only. dsp_map.v therefore asserts _TECHMAP_FAIL_ when
// mul2dsp offers it a signed $mul, the mapping is declined, `chtype -set $mul
// t:$__soft_mul` hands the cell to `alumacc`, and the design comes out as LUT4
// soft logic with ZERO mult_8 cells -- correct, just bigger.
//
// This is the control for the failure mode that actually costs you a week: a
// techmap file that accepts a cell it cannot model. Drop the _TECHMAP_FAIL_
// line from dsp_map.v and this example maps onto a DSP, reports beautiful cell
// counts, and computes the wrong product for every negative operand. The
// simulation check in run_synth.sh is what catches that, so the pair of
// controls only works with both halves running.

module mult_signed_8x8 (
  input  signed [7:0]  a,
  input  signed [7:0]  b,
  output signed [15:0] p
);
  assign p = a * b;
endmodule
