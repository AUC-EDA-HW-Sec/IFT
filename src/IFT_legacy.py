"""
    Initial approach to IFT generation. 
    This file is no longer used, but is kept for reference. 
    See src/IFT.py for the current implementation.
"""

from itertools import product
from pyeda.inter import exprvars, And, Or, espresso_exprs, truthtable, truthtable2expr
from EBLIF import *
from LUT import *
from Key import *

class IFT:
    def __init__(self, eblif_fileName):
        self.ebilf_fileName = eblif_fileName
        self.eblif = EBLIF(eblif_fileName)
        self.LUTs = self.eblif.LUTs
        self.input_names = self.eblif.input_names + [name + "_t" for name in self.eblif.input_names]
        self.output_names = self.eblif.output_names + [name + "_t" for name in self.eblif.output_names]
        self.vars = exprvars('v', len(self.input_names) + len(self.output_names))
        self.name_map = dict(zip(self.input_names + self.output_names, self.vars))
        self.number_of_LUTs = len(self.LUTs)
        self.output_expressions = {}
        self.map = {}

    def ift_logic_generation(self, lut_out, input_names):
        n = len(input_names)
        index = []
        c = 0
        full_space = 2 ** (2 * n)
        names = input_names + [name + '_t' for name in input_names]

        for i in range(len(lut_out)):
            for j in range(i + 1, len(lut_out)):
                if lut_out[i] != lut_out[j]:
                    addr = i
                    flipaddr = j ^ addr

                    truthstr = format(addr, f"0{n}b")
                    ift_str = format(flipaddr, f"0{n}b")
                    full_index = int(truthstr + ift_str, 2)

                    # Active variables
                    active_vars = []
                    for k, bit in enumerate(truthstr):
                        if bit == '1':
                            active_vars.append(input_names[k])
                    for k, bit in enumerate(ift_str):
                        if bit == '1':
                            active_vars.append(input_names[k] + 't')

                    # Generate matching indices (bits 1 must match, 0 = don't care)
                    matching_indices = []
                    for idx in range(full_space):
                        ok = True
                        # Check original inputs
                        for k, bit in enumerate(truthstr):
                            if bit == '1' and ((idx >> (2*n - 1 - k)) & 1) != 1:
                                ok = False
                        # Check taint inputs
                        for k, bit in enumerate(ift_str):
                            if bit == '1' and ((idx >> (n - 1 - k)) & 1) != 1:
                                ok = False
                        if ok:
                            matching_indices.append(idx)

                    c += 1
                    index.append(f"{full_index:b}".zfill(len(input_names)*2))
        return index, names
    
    def getMinterms(self, keys: list) -> set: # Get all output addresses from all keys
        output_addresses = set()
        for key in keys:
            output_addresses = output_addresses.union(key)
        return output_addresses
    
    def ift_equation(self, vars: list, minterms: list):
        terms = []
        for m in minterms:
            # Convert decimal index → bit vector (MSB first)
            bits = [(m >> i) & 1 for i in reversed(range(len(vars)))]
            # Create product term: var if bit=1 else ~var
            term = And(*[(var if bit else ~var) for var, bit in zip(vars, bits)])
            terms.append(term)

        # Combine all product terms (sum of products)
        f_expr = Or(*terms)
        minimal_expr, = espresso_exprs(f_expr)
        return f_expr, minimal_expr


    def run_ift_equation(self, LUT: LUT):
        lut_out = [int(bit) for bit in LUT.result[::-1]]
        print_lut = "".join(map(str, lut_out))
        print(f"LUT output: {print_lut}")
        logic_indices, names = self.ift_logic_generation(lut_out, LUT.input_names)
        print(f"Logic Indices: {[int(index, 2) for index in logic_indices]}")
        variables = [self.name_map[name] for name in names]
        keys = [Key(logic_index).getIntersection() for logic_index in logic_indices]
        # print(f"Keys: {keys}")
        minterms = self.getMinterms(keys)
        print(f"Minterms: {minterms}")
        first_expression, minimal_expression  = self.ift_equation(variables, minterms)
        # print(f"First Expression: {LUT.output_name} = {self.pretty(first_expression, name_map)}")
        # print(f"Minimal Expression: {LUT.output_name} = {self.pretty(minimal_expression)}")
        sop = truthtable(variables[0:len(variables)//2], LUT.result[::-1])
        self.output_expressions[LUT.output_name] = truthtable2expr(sop)
        self.output_expressions[LUT.output_name + "_t"] = minimal_expression
        not_tainted = self.pretty(self.output_expressions[LUT.output_name])
        tainted_name = LUT.output_name + "_t"
        tainted = self.pretty(self.output_expressions[tainted_name])
        print(f"Not tainted: {LUT.output_name} = {not_tainted}")
        print(f"Tainted: {tainted_name} = {tainted}")
        return first_expression, minimal_expression
    
    def run(self):
        print(f"Map: {self.name_map}")
        i = 1
        for lut in self.LUTs:
            print(f"LUT #{i}")
            first_expression, minimal_expression = self.run_ift_equation(lut)
            #print("Original Expression:", self.pretty(first_expression, name_map))
            # print("Minimal Expression :", self.pretty(minimal_expression) )
            i = i + 1
        return

    # Formatting
    def pretty(self, expr)-> str:
        # print(f"Before substitution: {str(expr)}")
        for key, value in self.output_expressions.items():
            sub = self.name_map[key]
            expr = expr.compose({sub: value})
        s = str(expr)
        for py_var, user_var in self.name_map.items():
            s = s.replace(str(user_var), py_var)
        return s.replace('Or', '|').replace('And', '&').replace('~', '~')

    
if __name__ == "__main__":
    ift = IFT("examples/or.eblif")
    ift.run()
