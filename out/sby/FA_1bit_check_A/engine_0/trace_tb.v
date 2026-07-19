`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [0:0] PI_Cin;
  reg [0:0] PI_Cin_t;
  reg [0:0] PI_B_t;
  reg [0:0] PI_B;
  reg [0:0] PI_A;
  reg [0:0] PI_A_t;
  FA_1bit UUT (
    .Cin(PI_Cin),
    .Cin_t(PI_Cin_t),
    .B_t(PI_B_t),
    .B(PI_B),
    .A(PI_A),
    .A_t(PI_A_t)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif

    // state 0
    PI_Cin = 1'b0;
    PI_Cin_t = 1'b0;
    PI_B_t = 1'b0;
    PI_B = 1'b0;
    PI_A = 1'b0;
    PI_A_t = 1'b1;
  end
  always @(posedge clock) begin
    genclock <= cycle < 0;
    cycle <= cycle + 1;
  end
endmodule
