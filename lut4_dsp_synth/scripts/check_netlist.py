#!/usr/bin/env python3
"""Structural checks on one synthesised design.

Reads the Yosys JSON netlist and the BLIF, and answers three questions that a
functional simulation cannot:

  1. Did the DSP blocks survive, and exactly as many as expected? A flow that
     lowered every multiplier into soft logic still simulates perfectly.
  2. Is everything else really LUT4? An unmapped `$add` or a stray `$mux` left
     in the netlist also simulates perfectly, and then fails at place-and-route.
  3. Does every `.subckt lut4` in the BLIF carry a `.param LUT` truth table?
     Forgetting `write_blif -param` produces a structurally complete netlist
     that computes nothing, and it is silent.

Exit status is 0 only if every check passes. Prints one machine-greppable
RESULT line either way.
"""

import argparse
import json
import re
import sys

# Cell types the target library actually has. Anything else in the netlist is a
# mapping failure, however harmless it looks.
ALLOWED_CELLS = {"lut4", "mult_8", "$_DFF_P_"}

DSP_CELL = "mult_8"
LUT_CELL = "lut4"
FF_CELL = "$_DFF_P_"


def load_top_cells(json_path, top):
    with open(json_path) as fh:
        design = json.load(fh)

    modules = design.get("modules", {})
    if top not in modules:
        # Yosys escapes some names; try the raw and the \-prefixed spelling.
        alt = [m for m in modules if m.lstrip("\\") == top]
        if not alt:
            raise KeyError(
                f"top module {top!r} not in JSON (have: {sorted(modules)})")
        top = alt[0]

    counts = {}
    for cell in modules[top].get("cells", {}).values():
        counts[cell["type"]] = counts.get(cell["type"], 0) + 1
    return counts


def check_blif(blif_path):
    """Return (n_lut_subckt, n_dsp_subckt, problems)."""
    problems = []
    with open(blif_path) as fh:
        lines = [ln.rstrip("\n") for ln in fh]

    n_lut = n_dsp = 0
    # Every `.subckt lut4` must be followed by its `.param LUT <bits>`.
    for i, ln in enumerate(lines):
        s = ln.strip()
        if s.startswith(".subckt " + LUT_CELL + " "):
            n_lut += 1
            nxt = lines[i + 1].strip() if i + 1 < len(lines) else ""
            m = re.match(r"^\.param\s+LUT\s+([01]+)\s*$", nxt)
            if not m:
                problems.append(
                    f"line {i+1}: .subckt {LUT_CELL} has no '.param LUT' on the "
                    f"next line (got {nxt!r}) -- was write_blif given -param?")
            elif len(m.group(1)) != 16:
                problems.append(
                    f"line {i+2}: .param LUT is {len(m.group(1))} bits, expected 16")
            # The IFT parser (src/LUT.py) takes the last token of the .subckt
            # line as the output. Enforce that here rather than let it silently
            # mis-parse.
            if not s.split()[-1].startswith("out="):
                problems.append(
                    f"line {i+1}: last port on the .subckt line is "
                    f"{s.split()[-1]!r}, but IFT/src/LUT.py assumes 'out=...'")
        elif s.startswith(".subckt " + DSP_CELL + " "):
            n_dsp += 1

    # `.names` with inputs means soft logic abc left behind as a truth table
    # instead of a lut4 cell. The three constant generators Yosys always emits
    # ($false/$true/$undef) are expected and take no inputs.
    for i, ln in enumerate(lines):
        s = ln.strip()
        if s.startswith(".names "):
            sig = s.split()[1:]
            if len(sig) > 1 and sig[0] not in ("$false", "$true", "$undef"):
                problems.append(
                    f"line {i+1}: leftover '.names' logic in BLIF: {s!r}")

    return n_lut, n_dsp, problems


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", required=True)
    ap.add_argument("--blif", required=True)
    ap.add_argument("--top", required=True)
    ap.add_argument("--expect-dsp", type=int, required=True,
                    help="required number of DSP (mult_8) cells")
    ap.add_argument("--expect-lut", choices=["zero", "nonzero", "any"],
                    default="any", help="required LUT4 population")
    args = ap.parse_args()

    problems = []

    try:
        counts = load_top_cells(args.json, args.top)
    except (OSError, KeyError, json.JSONDecodeError) as exc:
        print(f"RESULT {args.top} FAIL  could not read JSON netlist: {exc}")
        return 1

    n_dsp = counts.get(DSP_CELL, 0)
    n_lut = counts.get(LUT_CELL, 0)
    n_ff = counts.get(FF_CELL, 0)

    stray = {t: c for t, c in counts.items() if t not in ALLOWED_CELLS}
    if stray:
        problems.append(
            "netlist still contains cells outside the target library: "
            + ", ".join(f"{t}x{c}" for t, c in sorted(stray.items())))

    if n_dsp != args.expect_dsp:
        problems.append(
            f"DSP count is {n_dsp}, expected {args.expect_dsp}")

    if args.expect_lut == "zero" and n_lut != 0:
        problems.append(f"expected no LUT4, found {n_lut}")
    if args.expect_lut == "nonzero" and n_lut == 0:
        problems.append("expected LUT4 soft logic, found none")

    blif_lut, blif_dsp, blif_problems = check_blif(args.blif)
    problems.extend(blif_problems)

    # The two netlists describe the same design; if they disagree, one of the
    # two writers was handed the design in a different state.
    if blif_lut != n_lut:
        problems.append(
            f"BLIF has {blif_lut} lut4 subckts but JSON has {n_lut} lut4 cells")
    if blif_dsp != n_dsp:
        problems.append(
            f"BLIF has {blif_dsp} {DSP_CELL} subckts but JSON has {n_dsp}")

    summary = f"dsp={n_dsp} lut4={n_lut} dff={n_ff}"
    if problems:
        print(f"RESULT {args.top} FAIL  {summary}")
        for p in problems:
            print(f"    - {p}")
        return 1

    print(f"RESULT {args.top} PASS  {summary}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
