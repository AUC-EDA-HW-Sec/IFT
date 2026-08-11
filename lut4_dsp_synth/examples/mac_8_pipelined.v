// Example 5 -- a SEQUENTIAL design around a DSP.
//
// Registered multiply-accumulate with a synchronous clear and a clock enable.
// The point of this one is the flip-flop path: the target library has only a
// plain rising-edge D flop, so `dfflegalize -cell $_DFF_P_ 0` has to legalise
// the enable and the clear into that flop plus LUT4 soft logic. Expected:
// 1 mult_8, LUT4 for the adder and the enable/clear muxes, and 16 flops.
//
// It also checks that `memory_dff` and the `-nodffe -nosdff` opt flags in the
// script do not let a register drift into (or out of) the DSP.

module mac_8_pipelined (
  input             clk,
  input             rst,
  input             en,
  input      [7:0]  a,
  input      [7:0]  b,
  output reg [15:0] acc
);
  wire [15:0] prod = a * b;

  always @(posedge clk) begin
    if (rst)
      acc <= 16'h0000;
    else if (en)
      acc <= acc + prod;
  end
endmodule
