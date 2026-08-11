// ---------------------------------------------------------------------------
// cells_sim.v -- target cell library for the LUT4 + DSP synthesis flow.
//
// This file plays two roles:
//
//   1. Read with `read_verilog -lib -specify`, it declares the target cells to
//      Yosys as blackboxes. Blackboxes survive `flatten`, `techmap`, `abc` and
//      `opt_clean -purge`, which is exactly how a DSP block is *preserved*
//      rather than shredded into soft logic. This covers both DSPs that Yosys
//      infers from a `*` in the RTL and DSPs the RTL instantiates directly.
//
//   2. Read normally (by iverilog), the same bodies are simulation models, so
//      the synthesised netlist can be checked against the source RTL.
//
// Keep the port names and ORDER stable. `write_blif` emits `.subckt` port
// assignments in module-declaration order, and the IFT EBLIF parser
// (src/LUT.py) assumes the LUT's `out=` assignment is the LAST token on the
// `.subckt` line.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// lut4 -- the soft-logic cell. One 4-input LUT.
//
// The truth table travels as the 16-bit `LUT` parameter, so the BLIF must be
// written with `write_blif -param`; it then reads
//
//     .subckt lut4 in0=a in1=b in2=$false in3=$false out=y
//     .param LUT 1000100010001000
//
// which is the form already present in IFT/examples/*.eblif.
//
// Address ordering: in0 is the LSB, so out = LUT[{in3,in2,in1,in0}].
//
// X HANDLING IS NOT OPTIONAL HERE, and getting it wrong looks like a broken
// netlist rather than a broken model.
//
// The obvious one-liner, `assign out = LUT[{in3,in2,in1,in0}]`, returns X the
// moment ANY input is X, because the index is X. In a design with a synchronous
// reset that deadlocks: the flops power up to X, that X feeds back into the LUT
// computing their next value, the LUT returns X even with reset asserted, and
// the netlist never leaves X. Every vector mismatches and the netlist looks
// dead when it is fine.
//
// A physical LUT4 is an SRAM mux tree, and it does better than that: if the
// function does not depend on the unknown input, both sides of that mux stage
// carry the same value and the output is well defined. So the model below
// enumerates the addresses consistent with the inputs it does know, and returns
// a value if they all agree and X only if they genuinely disagree. That is what
// lets `rst` override a fed-back X, exactly as it does in hardware.
//
// This is faithfulness, not optimism -- it never resolves an output the mux
// tree would leave indeterminate. The fully-known case takes the direct index
// so the added cost lands only on vectors that actually carry an X.
// ---------------------------------------------------------------------------
module lut4 (in0, in1, in2, in3, out);
  parameter [15:0] LUT = 16'h0000;

  input  in0, in1, in2, in3;
  output out;

  // X (or Z) anywhere in the address makes the reduction XOR unknown.
  wire addr_known = ((^{in0, in1, in2, in3}) !== 1'bx);

  function resolve;
    input a0, a1, a2, a3;
    integer k;
    reg     val;
    reg     seen;
    reg [3:0] addr;
    begin
      seen = 1'b0;
      val  = 1'bx;
      for (k = 0; k < 16; k = k + 1) begin
        addr = k[3:0];
        // Is address k consistent with what we know? An input that is neither
        // 0 nor 1 constrains nothing, so both its values are in play.
        if (((a0 !== 1'b0 && a0 !== 1'b1) || a0 === addr[0]) &&
            ((a1 !== 1'b0 && a1 !== 1'b1) || a1 === addr[1]) &&
            ((a2 !== 1'b0 && a2 !== 1'b1) || a2 === addr[2]) &&
            ((a3 !== 1'b0 && a3 !== 1'b1) || a3 === addr[3])) begin
          if (!seen) begin
            val  = LUT[k];
            seen = 1'b1;
          end else if (LUT[k] !== val) begin
            val = 1'bx;      // the reachable entries disagree: genuinely unknown
          end
        end
      end
      resolve = val;
    end
  endfunction

  assign out = addr_known ? LUT[{in3, in2, in1, in0}]
                          : resolve(in0, in1, in2, in3);
endmodule

// ---------------------------------------------------------------------------
// mult_8 -- the DSP primitive: one unsigned 8x8 -> 16 multiplier.
//
// Name, widths and port names are taken verbatim from OpenFPGA's own dsp8
// technology library,
//   openfpga_flow/openfpga_yosys_techlib/
//     k4_frac_N8_tileable_reset_softadder_register_scan_chain_dsp8_nonLR_
//     caravel_io_skywater130nm_cell_sim.v
// so a netlist out of this flow drops straight onto an OpenFPGA architecture
// that carries a mult_8 block. `mult_8` is the cell that lands in the BLIF;
// `mult_8x8` (see dsp_map.v) is only the techmap intermediary.
//
// Note the [0:7] / [0:15] descending declaration: that too is OpenFPGA's, and
// it is load-bearing for BLIF port naming. Do not "tidy" it to [7:0].
// ---------------------------------------------------------------------------
module mult_8 (A, B, Y);
  input  [0:7]  A;
  input  [0:7]  B;
  output [0:15] Y;

  assign Y = A * B;
endmodule
