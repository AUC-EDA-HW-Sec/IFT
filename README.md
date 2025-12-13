# IFT - Information Flow Tracking for EBLIF Circuits

A Python library for parsing and analyzing Extended Berkeley Logic Interchange Format (EBLIF) circuit files using information flow tracking techniques.

## Overview

This project provides tools to parse EBLIF circuit descriptions, extract Look-Up Tables (LUTs), and generate information flow tracking logic for hardware security analysis.

## Features

- **EBLIF Parser**: Parse EBLIF circuit files and extract circuit components
- **LUT Extraction**: Identify and process Look-Up Tables from circuit descriptions
- **Information Flow Tracking**: Generate IFT logic for security analysis
- **Output Substitution**: After IFT generation, performs substitution on the output equations to express them in terms of actual circuit inputs (when intermediate LUT outputs are used as inputs)


## Project Structure

```
IFT/
├── src/              # Source code
│   ├── EBLIF.py      # EBLIF file parser
│   ├── LUT.py        # Look-Up Table representation
│   ├── IFT.py        # Information flow tracking logic
│   └── Key.py        # Key generation and manipulation
├── examples/         # Example EBLIF circuit files
│   ├── and.eblif
│   ├── FA_1bit.eblif
│   └── simple_full_adder_2bit_v2.eblif
├── requirements.txt  # Python dependencies
└── README.md         # This file
```

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd IFT
```

2. Create and activate a virtual environment (recommended):
```bash
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Linux/Mac:
source .venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Dependencies

- `pyeda` - Python Electronic Design Automation library for boolean algebra and logic minimization

## Usage

### Parsing EBLIF Files

```python
from src.EBLIF import EBLIF

# Parse an EBLIF file
eblif = EBLIF("examples/FA_1bit.eblif")

# Access extracted LUTs
for lut in eblif.LUTs:
    print("LUT Inputs:", lut.input_names)
    print("LUT Output:", lut.output_name)
```

### Information Flow Tracking

```python
from src.IFT import IFT

# Initialize IFT analysis
ift = IFT("examples/FA_1bit.eblif")

# Generate IFT logic (implementation details in IFT.py)
```

## Example Circuits

The `examples/` directory contains sample EBLIF circuit files:

- **and.eblif**: Simple AND gate circuit
- **FA_1bit.eblif**: 1-bit full adder
- **simple_full_adder_2bit_v2.eblif**: 2-bit full adder
