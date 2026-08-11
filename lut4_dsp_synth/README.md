# LUT4 + DSP synthesis flow

Synthesise RTL down to **LUT4 soft logic while preserving DSP blocks**, and emit
both a **Verilog** and a **BLIF** netlist from the same Yosys run.

The BLIF comes out in the EBLIF flavour this repo already uses — `.subckt lut4`
plus `.param LUT <16 bits>`, byte-compatible with the files in `../examples/` —
so it feeds `../src/EBLIF.py` directly.

---

## Quick start

`yosys` and `iverilog` must be on `PATH`. On this setup they live in the
multipass VM rather than on the macOS host:

```bash
ssh ubuntu@$(multipass info ubuntu --format csv | tail -1 | cut -d, -f3) 'cd ~/share/IFT/lut4_dsp_synth && ./run_synth.sh'
```

From inside the VM (or any machine with the tools):

```bash
./run_synth.sh                    # all eight designs
./run_synth.sh -d mac_8           # just one
./run_synth.sh --no-sim           # structural checks only
./run_synth.sh --keep-going       # report every failure instead of stopping
```

---

## Measured results

Whole set: **8/8 pass**, about **1 minute** wall clock. Every number below is
measured, on Yosys 0.33 and Icarus Verilog 12.0.

| Design | DSP | LUT4 | DFF | What it demonstrates | Functional check |
|---|---:|---:|---:|---|---|
| `mult_8x8_infer` | 1 | 0 | 0 | plain 8×8 inference — one DSP, no soft logic at all | 4009 vectors |
| `mac_8` | 1 | 35 | 0 | design split across both resources: DSP multiply, LUT4 adder | 4001 vectors |
| `mult_16x16_split` | 4 | 97 | 0 | multiply **wider** than the block → 4 partial products + adder tree | 4009 vectors |
| `mult_direct_inst` | 1 | 16 | 0 | DSP **instantiated** in the RTL, not inferred | 4001 vectors |
| `mac_8_pipelined` | 1 | 54 | 16 | sequential: clock enable and sync clear legalised onto a plain D flop | 3000 cycles |
| `dsp_datapath` | 2 | 62 | 18 | **two** DSPs beside an FSM, mux and XOR; both stay hard | 3000 cycles, both FSM arms |
| `mult_1x1_soft` | **0** | 2 | 0 | negative control: too narrow for a DSP, stays soft | 8 vectors, exhaustive |
| `mult_signed_8x8` | **0** | 182 | 0 | negative control: signed, which the unsigned block cannot express | 65536 vectors, exhaustive |

The two zero-DSP rows are the point of the set. Without them, a flow that maps
every `*` onto a DSP looks identical to a correct one — and `mult_signed_8x8`
shows why that matters: it is **functionally perfect over all 65536 operand
pairs while containing no DSP at all**. Function and mapping are independent
claims and need independent checks.

---

## How DSPs are preserved

Two distinct paths, both covered:

- **Inferred** (`a * b` in the RTL). `techmap -map +/mul2dsp.v -map dsp_map.v`
  decomposes each `$mul` into blocks no larger than the primitive and rewrites
  them onto it. Wider multiplies are split (hence 4 DSPs for 16×16); narrower
  ones than `DSP_[AB]_MINWIDTH` are deliberately left in LUTs.
- **Instantiated** (the RTL names `mult_8` itself). This rests entirely on
  `read_verilog -lib -specify scripts/cells_sim.v`, which makes the target cells
  blackboxes. `flatten` will not inline a blackbox, `abc` never sees inside one,
  and `opt_clean -purge` will not dissolve it.

`scripts/lut4_dsp.ys.tmpl` follows OpenFPGA's own
`openfpga_flow/misc/ys_tmpl_yosys_vpr_dsp_flow.ys`, and the primitive matches
their `dsp8` techlib cell in name, widths and port names, so a netlist from here
drops onto an OpenFPGA architecture carrying a `mult_8`. Deviations from their
template are commented in the file; the main one is step 7, which converts
`$lut` into explicit `lut4` cells so the BLIF carries `.subckt`/`.param` instead
of `.names`.

---

## Layout

```
lut4_dsp_synth/
├── run_synth.sh                    driver: substitute, synthesise, check, simulate
├── scripts/
│   ├── lut4_dsp.ys.tmpl            THE Yosys script (templated; heavily commented)
│   ├── cells_sim.v                 target library: lut4 + mult_8 (blackboxes AND sim models)
│   ├── dsp_map.v                   mul2dsp's DSP_NAME cell -> the real mult_8
│   ├── map_lut_to_lut4.v           $lut -> explicit lut4 cells
│   ├── simcells_dff.v              simulation-only model of Yosys' $_DFF_P_
│   └── check_netlist.py            structural assertions on JSON + BLIF
├── examples/                       eight RTL designs (six with DSP, two controls)
├── verify/                         one self-checking testbench per design
└── out/<design>/                   generated netlists, per design
```

`run_synth.sh` writes the substituted Yosys script to `out/<design>/<design>.ys`,
so any run can be reproduced by hand with `yosys -s out/<design>/<design>.ys`.

---

## What is checked, and what a pass means

`check_netlist.py` asserts three things a simulation cannot:

1. **Exact DSP count.** A netlist that quietly stopped preserving DSPs still
   simulates perfectly.
2. **Nothing outside the target library.** A leftover `$add` or `$mux` also
   simulates perfectly, then fails at place-and-route.
3. **Every `.subckt lut4` has a `.param LUT`.** Forgetting `write_blif -param`
   yields a structurally complete netlist that computes nothing, silently.

Then each design is simulated against a golden model computed in the testbench.

Both halves were negative-tested — the checks are known to catch real
regressions, not merely to pass:

- Dropping `-param` from `write_blif` → caught, naming the missing `.param LUT`
  and the likely cause.
- Making `mult_8` a normal module instead of a blackbox → **fails loudly** at
  `hierarchy -check` (`Module '\mult_8' ... is not part of the design`). Worth
  recording because the plausible guess is wrong: it does *not* quietly come out
  as ~150 LUT4. Verified two ways — the whole library read without `-lib`, and
  `mult_8` alone given a body while `lut4` stayed a blackbox.

---

## Three traps found while building this

Each cost real time and each fails quietly.

**A behavioural `LUT[{in3,in2,in1,in0}]` model deadlocks any design with a
reset.** The index goes X the moment one input is X, so the flops power up to X,
that X feeds back through the LUT computing their next value, and the LUT returns
X *even with reset asserted*. Every vector mismatches and the netlist looks dead
when it is fine. A physical LUT4 is an SRAM mux tree and does better: if the
function does not depend on the unknown input, both sides of that mux stage carry
the same value. `cells_sim.v` therefore enumerates the addresses consistent with
the known inputs and returns X only if they genuinely disagree. This is
faithfulness, not optimism — and it is what fixed `mac_8_pipelined`.

**`_TECHMAP_FAIL_` is the wrong place to reject a cell the primitive cannot
express.** Both maps run in one `techmap` pass: `mul2dsp` rewrites `$mul` into
`DSP_NAME` cells first, and if the second map then declines one, the first
rewrite is **not** rolled back. You get a `mult_8x8` cell with no module of that
name. Signed multiplies are filtered up front instead, in the selection
(`select -set dsp_mul t:$mul r:A_SIGNED=0 %i r:B_SIGNED=0 %i`); the
`_TECHMAP_FAIL_` stays only as a backstop.

**An expression inside a Verilog concatenation is self-determined.** The
`dsp_datapath` testbench wrote its golden value as `{1'b0, x0 * w0}`, which is an
**8-bit** multiply — truncated — while the RTL's `wire [15:0] m0 = x0 * w0` keeps
all 16 bits. The testbench disagreed with a perfectly correct netlist on 2976 of
3000 vectors, which reads exactly like a flow bug. Golden values now go through
their own explicitly-sized regs.

Two smaller ones, both handled in the flow: `write_blif` needs **`-noalias`**, or
it emits a fanout-less `.names <canonical> <alias>` / `1 1` for every shadowed
net name (`mul2dsp`'s generate blocks produce a lot of them) — VPR would pack
each as a LUT1, and IFT ignores `.names`, so a LUT input known only by an alias
would look like a primary input. And Yosys builds autogenerated net names from
the **source file path**, so `run_synth.sh` runs from this directory with
relative paths; absolute ones put the build machine's directory layout inside
every netlist and inside IFT's variable names.

---

## Handing the BLIF to IFT — verified, with two real gaps

`out/<design>/<design>.eblif` is a copy under the name and extension
`../src/EBLIF.py` expects. Verified end to end on `mac_8`: the parser reads
**35 of 35** LUTs with correct 16-bit truth tables.

Two limitations to know before relying on it. Both are pre-existing properties of
`src/EBLIF.py`, but this folder is what makes them reachable:

- **DSP blocks are invisible to IFT.** `EBLIF.parseFile` only matches
  `.subckt lut`, so `.subckt mult_8` is skipped entirely. The DSP's output nets
  therefore look like primary inputs, and **taint does not propagate through a
  multiplier**. For a flow whose whole purpose is preserving DSPs, that is the
  next thing to close.
- **Flip-flops are invisible too.** Yosys writes them in BLIF's native form,
  `.latch <d> <q> re <clk> 2`, which the parser also skips — so the sequential
  designs (`mac_8_pipelined`, `dsp_datapath`) present to IFT as combinational
  fragments.

The unmasked combinational designs (`mult_8x8_infer` aside, which has no LUTs at
all) are consumable today; the rest need those two cases handled.

---

## Knobs

At the top of `run_synth.sh`:

| Variable | Default | Meaning |
|---|---|---|
| `LUT_SIZE` | `4` | `abc -lut N`. Above 4, `map_lut_to_lut4.v` rejects via `_TECHMAP_FAIL_` rather than truncate. |
| `DSP_A_MAXWIDTH` / `DSP_B_MAXWIDTH` | `8` | the primitive's real size; wider multiplies get decomposed |
| `DSP_A_MINWIDTH` / `DSP_B_MINWIDTH` | `2` | policy floor — narrower multiplies stay in LUTs |
| `DSP_NAME` | `mult_8x8` | the `mul2dsp` intermediary; the cell that lands in the netlist is `mult_8` |

Defaults are OpenFPGA's own, from
`openfpga_flow/tasks/fpga_verilog/dsp/single_mode_mult_8x8/config/task.conf`.

To target a different DSP, change `mult_8` in `cells_sim.v` and `dsp_map.v` and
the widths above. To add a design: drop the RTL in `examples/`, a testbench in
`verify/tb_<name>.v`, and one line in the `DESIGNS` table.
