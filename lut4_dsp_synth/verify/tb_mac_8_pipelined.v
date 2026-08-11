`timescale 1ns/1ps
// Sequential check. The netlist's flops power up to X, so the run opens with a
// reset cycle; from then on a golden accumulator in the testbench must track the
// netlist exactly, cycle for cycle.
//
// `en` is driven low on a third of the cycles on purpose -- the clock enable is
// the part dfflegalize had to synthesise out of a plain D flop plus a mux, and a
// design that ignores `en` still passes a test that holds it high throughout.
module tb_mac_8_pipelined;
  reg         clk, rst, en;
  reg  [7:0]  a, b;
  wire [15:0] acc;
  reg  [15:0] gold;
  integer i, errors, checks;

  mac_8_pipelined dut (.clk(clk), .rst(rst), .en(en), .a(a), .b(b), .acc(acc));

  always #5 clk = ~clk;

  initial begin
    clk = 0; rst = 1; en = 0; a = 0; b = 0;
    errors = 0; checks = 0;

    // One reset cycle to get the netlist out of X.
    @(posedge clk); #1; gold = 16'h0000;
    rst = 0;

    for (i = 0; i < 3000; i = i + 1) begin
      a  = $random;
      b  = $random;
      en = ($random % 3) != 0;
      rst = (i != 0) && (i % 250 == 0);   // periodic clear, exercised mid-stream

      @(posedge clk);
      // Golden update, same semantics as the RTL.
      if (rst)      gold = 16'h0000;
      else if (en)  gold = gold + (a * b);

      #1;
      checks = checks + 1;
      if (acc !== gold) begin
        errors = errors + 1;
        if (errors <= 10)
          $display("MISMATCH cyc=%0d rst=%b en=%b a=%h b=%h got=%h exp=%h",
                   i, rst, en, a, b, acc, gold);
      end
    end

    if (errors == 0) $display("SIM PASS mac_8_pipelined (%0d cycles)", checks);
    else             $display("SIM FAIL mac_8_pipelined (%0d errors)", errors);
    $finish;
  end
endmodule
