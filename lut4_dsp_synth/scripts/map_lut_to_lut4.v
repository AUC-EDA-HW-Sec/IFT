// ---------------------------------------------------------------------------
// map_lut_to_lut4.v -- turn Yosys' internal $lut cells into explicit `lut4`
// cells, so that `write_blif -param` emits the
//
//     .subckt lut4 in0=... in1=... in2=... in3=... out=...
//     .param LUT <16 bits, MSB first>
//
// form that IFT/src/EBLIF.py already parses.
//
// $lut carries:  parameter WIDTH, parameter [2**WIDTH-1:0] LUT,
//                input [WIDTH-1:0] A, output Y
//
// `abc -lut 4` only ever produces WIDTH <= 4, so anything wider is a flow bug
// and is rejected via _TECHMAP_FAIL_ rather than silently truncated.
//
// UNUSED INPUTS: for WIDTH < 4 the spare inputs are tied to 1'b0 (which
// `write_blif` renders as `in3=$false`) and the truth table is REPLICATED to
// fill 16 bits rather than zero-extended.
//
// Replication matters, twice over:
//
//   * It makes the cell's output independent of what the spare input actually
//     reads. A zero-extended INIT is only correct if the unused pin really is
//     0; if anything downstream -- a fabric that drives unrouted mux inputs
//     high, or a consumer that reads the LUT's upper half -- presents a 1, a
//     zero-extended table returns 0 where the logic wanted a real value.
//   * It is what produced the existing examples/*.eblif. and2 gives
//     {4{4'b1000}} = 1000100010001000, and FA_1bit's Cout gives
//     {2{8'b11101000}} = 1110100011101000 -- both byte-for-byte what those
//     files contain. Changing this would fork the LUT convention.
// ---------------------------------------------------------------------------

module \$lut (A, Y);
  parameter integer WIDTH = 0;
  parameter [2**WIDTH-1:0] LUT = 0;

  input  [WIDTH-1:0] A;
  output Y;

  wire _TECHMAP_FAIL_ = (WIDTH > 4);

  generate
    if (WIDTH == 0) begin
      assign Y = LUT[0];
    end else if (WIDTH == 1) begin
      lut4 #(.LUT({8{LUT[1:0]}})) _TECHMAP_REPLACE_ (
        .in0 (A[0]), .in1 (1'b0), .in2 (1'b0), .in3 (1'b0), .out (Y));
    end else if (WIDTH == 2) begin
      lut4 #(.LUT({4{LUT[3:0]}})) _TECHMAP_REPLACE_ (
        .in0 (A[0]), .in1 (A[1]), .in2 (1'b0), .in3 (1'b0), .out (Y));
    end else if (WIDTH == 3) begin
      lut4 #(.LUT({2{LUT[7:0]}})) _TECHMAP_REPLACE_ (
        .in0 (A[0]), .in1 (A[1]), .in2 (A[2]), .in3 (1'b0), .out (Y));
    end else begin
      lut4 #(.LUT(LUT[15:0])) _TECHMAP_REPLACE_ (
        .in0 (A[0]), .in1 (A[1]), .in2 (A[2]), .in3 (A[3]), .out (Y));
    end
  endgenerate
endmodule
