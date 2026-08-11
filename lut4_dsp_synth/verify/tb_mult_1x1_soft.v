`timescale 1ns/1ps
// Exhaustive: three inputs, eight cases.
module tb_mult_1x1_soft;
  reg  a, b, c;
  wire p, q;
  integer i, errors;

  mult_1x1_soft dut (.a(a), .b(b), .c(c), .p(p), .q(q));

  initial begin
    errors = 0;
    for (i = 0; i < 8; i = i + 1) begin
      a = i[0]; b = i[1]; c = i[2];
      #1;
      if (p !== (a & b) || q !== ((a & b) ^ c)) begin
        errors = errors + 1;
        $display("MISMATCH a=%b b=%b c=%b got p=%b q=%b exp p=%b q=%b",
                 a, b, c, p, q, (a & b), ((a & b) ^ c));
      end
    end
    if (errors == 0) $display("SIM PASS mult_1x1_soft (8 vectors, exhaustive)");
    else             $display("SIM FAIL mult_1x1_soft (%0d errors)", errors);
    $finish;
  end
endmodule
