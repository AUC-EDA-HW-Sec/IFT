// Example 6 -- TWO DSPs alongside genuine control logic.
//
// A small sum-of-products datapath with a 2-state FSM selecting which operand
// pair feeds the output, plus an XOR whitening stage. This is the realistic
// case: hard multipliers embedded in a design that also has state, muxing and
// bit-level logic, all of which must go to LUT4 while both multipliers stay
// hard.
//
// Expected: 2 mult_8 (the two products are independent, so `share` cannot fold
// them onto one block), LUT4 for the adder / mux / FSM / XOR, and flops for the
// state bit and the output register.

module dsp_datapath (
  input             clk,
  input             rst,
  input             sel,
  input      [7:0]  x0,
  input      [7:0]  x1,
  input      [7:0]  w0,
  input      [7:0]  w1,
  input      [15:0] key,
  output reg [16:0] y
);
  wire [15:0] m0 = x0 * w0;
  wire [15:0] m1 = x1 * w1;

  // One state bit of control, toggled by sel.
  reg state;
  always @(posedge clk) begin
    if (rst) state <= 1'b0;
    else     state <= state ^ sel;
  end

  reg [16:0] mixed;
  always @(*) begin
    case (state)
      1'b0:    mixed = {1'b0, m0} + {1'b0, m1};   // sum of products
      default: mixed = {1'b0, m0 ^ m1};           // bitwise mix
    endcase
  end

  always @(posedge clk) begin
    if (rst) y <= 17'h00000;
    else     y <= mixed ^ {1'b0, key};
  end
endmodule
