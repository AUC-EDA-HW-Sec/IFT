`timescale 1ns/1ps
// Combinational check of the synthesised netlist against a behavioural golden
// value computed here in the testbench. The netlist is the only DUT, which
// avoids the module-name collision you get from instantiating RTL and netlist
// side by side.
module tb_mult_8x8_infer;
  reg  [7:0]  a, b;
  wire [15:0] p;
  reg  [15:0] exp;
  integer i, errors;

  mult_8x8_infer dut (.a(a), .b(b), .p(p));

  initial begin
    errors = 0;
    // Corners first: 0, 1 and all-ones in both operands.
    for (i = 0; i < 9; i = i + 1) begin
      a = (i % 3 == 0) ? 8'h00 : (i % 3 == 1) ? 8'h01 : 8'hff;
      b = (i / 3 == 0) ? 8'h00 : (i / 3 == 1) ? 8'h01 : 8'hff;
      #1; exp = a * b;
      if (p !== exp) begin
        errors = errors + 1;
        if (errors <= 10) $display("MISMATCH a=%h b=%h got=%h exp=%h", a, b, p, exp);
      end
    end
    for (i = 0; i < 4000; i = i + 1) begin
      a = $random; b = $random;
      #1; exp = a * b;
      if (p !== exp) begin
        errors = errors + 1;
        if (errors <= 10) $display("MISMATCH a=%h b=%h got=%h exp=%h", a, b, p, exp);
      end
    end
    if (errors == 0) $display("SIM PASS mult_8x8_infer (4009 vectors)");
    else             $display("SIM FAIL mult_8x8_infer (%0d errors)", errors);
    $finish;
  end
endmodule
