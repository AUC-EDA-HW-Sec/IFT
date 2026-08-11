`timescale 1ns/1ps
// EXHAUSTIVE, all 65536 signed operand pairs.
//
// Worth the cost: this is the example whose whole purpose is to prove the
// unsigned DSP was declined. If dsp_map.v ever accepts a signed $mul, the
// netlist is wrong precisely on negative operands -- which random vectors would
// catch, but exhaustion proves.
module tb_mult_signed_8x8;
  reg  signed [7:0]  a, b;
  wire signed [15:0] p;
  reg  signed [15:0] exp;
  integer ia, ib, errors;

  mult_signed_8x8 dut (.a(a), .b(b), .p(p));

  initial begin
    errors = 0;
    for (ia = -128; ia <= 127; ia = ia + 1) begin
      for (ib = -128; ib <= 127; ib = ib + 1) begin
        a = ia; b = ib;
        #1; exp = a * b;
        if (p !== exp) begin
          errors = errors + 1;
          if (errors <= 10)
            $display("MISMATCH a=%0d b=%0d got=%0d exp=%0d", a, b, p, exp);
        end
      end
    end
    if (errors == 0) $display("SIM PASS mult_signed_8x8 (65536 vectors, exhaustive)");
    else             $display("SIM FAIL mult_signed_8x8 (%0d errors)", errors);
    $finish;
  end
endmodule
