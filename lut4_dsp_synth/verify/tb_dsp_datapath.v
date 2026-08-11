`timescale 1ns/1ps
// Sequential check with a golden model of both the state bit and the output
// register. `sel` toggles the FSM, so both arms of the `case` (sum-of-products
// and bitwise mix) are exercised; a netlist that lost the mux would pass on one
// arm alone.
module tb_dsp_datapath;
  reg         clk, rst, sel;
  reg  [7:0]  x0, x1, w0, w1;
  reg  [15:0] key;
  wire [16:0] y;

  reg         g_state;
  reg  [16:0] g_mixed, g_y;
  // m0/m1 must be their own 16-bit regs, NOT written inline as `{1'b0, x0*w0}`.
  // An expression inside a concatenation is self-determined in Verilog, so
  // `x0 * w0` there is an EIGHT-bit multiply and the product is truncated --
  // while the RTL's `wire [15:0] m0 = x0 * w0` keeps all 16 bits. Written the
  // inline way this testbench disagrees with a perfectly correct netlist on
  // roughly 99% of random vectors, which reads exactly like a flow bug.
  reg  [15:0] g_m0, g_m1;
  integer i, errors, checks, arm0, arm1;

  dsp_datapath dut (.clk(clk), .rst(rst), .sel(sel),
                    .x0(x0), .x1(x1), .w0(w0), .w1(w1), .key(key), .y(y));

  always #5 clk = ~clk;

  initial begin
    clk = 0; rst = 1; sel = 0;
    x0 = 0; x1 = 0; w0 = 0; w1 = 0; key = 0;
    errors = 0; checks = 0; arm0 = 0; arm1 = 0;

    @(posedge clk); #1;
    g_state = 1'b0; g_y = 17'h00000;
    rst = 0;

    for (i = 0; i < 3000; i = i + 1) begin
      x0 = $random; x1 = $random; w0 = $random; w1 = $random; key = $random;
      sel = $random;
      rst = (i != 0) && (i % 400 == 0);

      // Combinational golden value, computed from the state BEFORE this edge.
      g_m0 = x0 * w0;
      g_m1 = x1 * w1;
      if (g_state == 1'b0) g_mixed = {1'b0, g_m0} + {1'b0, g_m1};
      else                 g_mixed = {1'b0, (g_m0 ^ g_m1)};

      if (g_state == 1'b0) arm0 = arm0 + 1; else arm1 = arm1 + 1;

      @(posedge clk);
      if (rst) begin
        g_y     = 17'h00000;
        g_state = 1'b0;
      end else begin
        g_y     = g_mixed ^ {1'b0, key};
        g_state = g_state ^ sel;
      end

      #1;
      checks = checks + 1;
      if (y !== g_y) begin
        errors = errors + 1;
        if (errors <= 10)
          $display("MISMATCH cyc=%0d state=%b rst=%b got=%h exp=%h",
                   i, g_state, rst, y, g_y);
      end
    end

    $display("  FSM arm coverage: state=0 %0d cycles, state=1 %0d cycles", arm0, arm1);
    if (arm0 == 0 || arm1 == 0)
      $display("SIM FAIL dsp_datapath (an FSM arm was never exercised)");
    else if (errors == 0)
      $display("SIM PASS dsp_datapath (%0d cycles)", checks);
    else
      $display("SIM FAIL dsp_datapath (%0d errors)", errors);
    $finish;
  end
endmodule
