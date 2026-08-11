`timescale 1ns/1ps
// The decomposition case: this netlist computes a 32-bit product out of four
// 8x8 DSPs and a soft adder tree. A single wrong shift in that tree gives a
// product that is right for small operands and wrong for large ones, so the
// corner vectors below are not decoration.
module tb_mult_16x16_split;
  reg  [15:0] a, b;
  wire [31:0] p;
  reg  [31:0] exp;
  integer i, errors;

  mult_16x16_split dut (.a(a), .b(b), .p(p));

  task check;
    begin
      #1; exp = a * b;
      if (p !== exp) begin
        errors = errors + 1;
        if (errors <= 10) $display("MISMATCH a=%h b=%h got=%h exp=%h", a, b, p, exp);
      end
    end
  endtask

  initial begin
    errors = 0;
    // Corners that exercise each partial product and the shifts between them.
    a = 16'h0000; b = 16'hffff; check;
    a = 16'hffff; b = 16'h0000; check;
    a = 16'hffff; b = 16'hffff; check;   // full-width product
    a = 16'h0001; b = 16'hffff; check;
    a = 16'hff00; b = 16'hff00; check;   // high byte only  -> upper partials
    a = 16'h00ff; b = 16'h00ff; check;   // low byte only   -> lower partial
    a = 16'hff00; b = 16'h00ff; check;   // cross terms
    a = 16'h00ff; b = 16'hff00; check;
    a = 16'h8000; b = 16'h8000; check;
    for (i = 0; i < 4000; i = i + 1) begin
      a = $random; b = $random; check;
    end
    if (errors == 0) $display("SIM PASS mult_16x16_split (4009 vectors)");
    else             $display("SIM FAIL mult_16x16_split (%0d errors)", errors);
    $finish;
  end
endmodule
