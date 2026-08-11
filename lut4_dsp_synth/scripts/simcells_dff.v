// ---------------------------------------------------------------------------
// simcells_dff.v -- SIMULATION ONLY. Not part of the target cell library.
//
// The flow maps every flip-flop onto Yosys' internal `$_DFF_P_` (a plain
// rising-edge D type) via `dfflegalize -cell $_DFF_P_ 0`. Yosys knows that cell
// intrinsically; iverilog does not, so a netlist with flops fails to elaborate
// with "Unknown module type: $_DFF_P_" until something defines it. This is that
// definition, and it is the same model as Yosys' own +/simcells.v.
//
// It is a separate file from cells_sim.v on purpose. cells_sim.v is read into
// Yosys with `-lib` to declare the target cells; declaring a blackbox with the
// name of a Yosys built-in there would shadow the real thing.
//
// Nothing downstream of Yosys needs this file: the BLIF represents the same
// flop natively as `.latch <d> <q> re <clk> 2`, so VPR and OpenFPGA never see
// the `$_DFF_P_` name at all. It exists so the written VERILOG can be
// simulated.
//
// Power-up value is left at X deliberately -- it is what the hardware does, and
// the testbenches open with a reset cycle rather than assuming otherwise. A
// model that powered up to 0 here would hide a design that needs a reset it
// does not have.
// ---------------------------------------------------------------------------

module \$_DFF_P_ (D, C, Q);
  input  D, C;
  output reg Q;

  always @(posedge C) Q <= D;
endmodule
