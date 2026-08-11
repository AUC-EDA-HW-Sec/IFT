`timescale 1ns/1ps
module tb_mac_8;
  reg  [7:0]  a, b;
  reg  [15:0] c;
  wire [15:0] p;
  reg  [15:0] exp;
  integer i, errors;

  mac_8 dut (.a(a), .b(b), .c(c), .p(p));

  initial begin
    errors = 0;
    // Include the carry-out corner: 0xff*0xff + 1 wraps the 16-bit sum.
    a = 8'hff; b = 8'hff; c = 16'h0001; #1;
    exp = a * b + c;
    if (p !== exp) begin
      errors = errors + 1;
      $display("MISMATCH (wrap) a=%h b=%h c=%h got=%h exp=%h", a, b, c, p, exp);
    end
    for (i = 0; i < 4000; i = i + 1) begin
      a = $random; b = $random; c = $random;
      #1; exp = a * b + c;
      if (p !== exp) begin
        errors = errors + 1;
        if (errors <= 10) $display("MISMATCH a=%h b=%h c=%h got=%h exp=%h", a, b, c, p, exp);
      end
    end
    if (errors == 0) $display("SIM PASS mac_8 (4001 vectors)");
    else             $display("SIM FAIL mac_8 (%0d errors)", errors);
    $finish;
  end
endmodule
