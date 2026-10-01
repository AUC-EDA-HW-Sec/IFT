#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No design name provided."
    echo "Usage: source ./run_flow.tcl <design_name>"
    return 1 2>/dev/null || exit 1
fi

DESIGN_NAME=$1

# Invoke Yosys with the internal Tcl runner to pass $DESIGN_NAME into $argv
yosys -p "tcl synth_flow.tcl $DESIGN_NAME"

##########################################################

# Check if Yosys succeeded
if [ $? -ne 0 ]; then
    echo "Synthesis failed."
    return 1 2>/dev/null || exit 1
fi

OUTPUT_FILE="./${DESIGN_NAME}/outputs/eblif/${DESIGN_NAME}.eblif"
if [ ! -s "$OUTPUT_FILE" ]; then
    echo "Synthesis completed, but the EBLIF output was not created: $OUTPUT_FILE"
    return 1 2>/dev/null || exit 1
fi

echo "Yosys succeeded. EBLIF written to: $OUTPUT_FILE"

# Run IFT on the generated EBLIF and keep its artifacts under the design outputs directory.
PYTHON_BIN=".venv/bin/python"
if [ ! -x "$PYTHON_BIN" ]; then
    PYTHON_BIN="python3"
fi

"$PYTHON_BIN" src/IFT.py "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "IFT analysis failed."
    return 1 2>/dev/null || exit 1
fi

echo "IFT analysis completed. Outputs written to: ./${DESIGN_NAME}/outputs"
