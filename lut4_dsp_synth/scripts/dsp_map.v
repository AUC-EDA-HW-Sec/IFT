// ---------------------------------------------------------------------------
// dsp_map.v -- second stage of the $mul -> DSP mapping.
//
// Yosys' own +/mul2dsp.v does the hard part: it decomposes an arbitrarily
// sized $mul into a collection of `DSP_NAME cells no wider than
// DSP_A_MAXWIDTH x DSP_B_MAXWIDTH, wired together with $shl/$add cells (which
// later become LUT4 soft logic). It emits those cells carrying $mul's OWN
// interface -- parameters A_SIGNED/B_SIGNED/A_WIDTH/B_WIDTH/Y_WIDTH and ports
// A/B/Y -- and it does NOT know the real primitive's shape.
//
// This file is the adaptor from that interface to the real primitive: one
// module named after the DSP_NAME handed to mul2dsp (`mult_8x8`), rewritten
// into the `mult_8` blackbox declared in cells_sim.v.
//
// Structure copied from OpenFPGA's
// openfpga_flow/openfpga_yosys_techlib/..._dsp8_..._dsp_map.v so that the two
// flows stay interchangeable.
// ---------------------------------------------------------------------------

module mult_8x8 (A, B, Y);
  parameter A_SIGNED = 0;
  parameter B_SIGNED = 0;
  parameter A_WIDTH  = 0;
  parameter B_WIDTH  = 0;
  parameter Y_WIDTH  = 0;

  input  [0:7]  A;
  input  [0:7]  B;
  output [0:15] Y;

  // Only unsigned multiplication is modelled by the mult_8 primitive. Refuse
  // the mapping rather than emit a silently wrong netlist: a failed techmap
  // leaves the $mul in place, where `techmap`/`alumacc` turn it into correct
  // (if larger) LUT4 soft logic. See examples/mult_signed_8x8.v.
  wire _TECHMAP_FAIL_ = A_SIGNED || B_SIGNED;

  mult_8 _TECHMAP_REPLACE_ (
    .A (A),
    .B (B),
    .Y (Y)
  );
endmodule
