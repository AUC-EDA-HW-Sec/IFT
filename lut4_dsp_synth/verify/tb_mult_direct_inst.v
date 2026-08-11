`timescale 1ns/1ps
module tb_mult_direct_inst;
  reg  [7:0]  a, b;
  reg  [15:0] mask;
  wire [15:0] p;
  reg  [15:0] exp;
  integer i, errors;

  mult_direct_inst dut (.a(a), .b(b), .mask(mask), .p(p));

  initial begin
    errors = 0;
    a = 8'hff; b = 8'hff; mask = 16'h0000; #1;
    exp = (a * b) ^ mask;
    if (p !== exp) begin
      errors = errors + 1;
      $display("MISMATCH (corner) a=%h b=%h mask=%h got=%h exp=%h", a, b, mask, p, exp);
    end
    for (i = 0; i < 4000; i = i + 1) begin
      a = $random; b = $random; mask = $random;
      #1; exp = (a * b) ^ mask;
      if (p !== exp) begin
        errors = errors + 1;
        if (errors <= 10) $display("MISMATCH a=%h b=%h mask=%h got=%h exp=%h", a, b, mask, p, exp);
      end
    end
    if (errors == 0) $display("SIM PASS mult_direct_inst (4001 vectors)");
    else             $display("SIM FAIL mult_direct_inst (%0d errors)", errors);
    $finish;
  end
endmodule
