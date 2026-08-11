// Example 7 -- NEGATIVE CONTROL: a multiply too narrow to earn a DSP.
//
// A 1x1 multiply is an AND gate. mul2dsp is told DSP_A_MINWIDTH / DSP_B_MINWIDTH
// and leaves anything below them alone, so this must come out as soft logic with
// ZERO mult_8 cells.
//
// The control matters because a flow that maps every `*` to a DSP looks
// identical to a correct one on examples 1-6. Only a case that is supposed NOT
// to map can tell "preserves DSPs" apart from "preserves DSPs selectively", and
// only the second is useful -- burning a hard multiplier on an AND gate is a
// real cost on a fabric with a handful of them.

module mult_1x1_soft (
  input  a,
  input  b,
  input  c,
  output p,
  output q
);
  assign p = a * b;
  assign q = (a * b) ^ c;
endmodule
