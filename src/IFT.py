from itertools import product
from pyeda.inter import expr, exprvars, And, Or, espresso_exprs, truthtable, truthtable2expr
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
        self.vars = exprvars('v', len(self.input_names))
        self.name_map = dict(zip(self.input_names, self.vars))
        self.number_of_LUTs = len(self.LUTs)
        self.output_expressions = {}
        self.map = {}
    
    def ift_logic_generation(self, lut: LUT):
        """
        Generate IFT logic for a given LUT
        Application of the IFT generation algorithm from "LUT Level Information Flow Tracking for FPGA Design Security Verification" by Zhang et al.
        Input: LUT object containing the LUT's output truth table and input names
        Logic:
            - For each pair of output values in the LUT's truth table, identify pairs that differ (i.e., one is 0 and the other is 1)
            - For each differing pair, determine the input combination (truth_str) that produces the first output value, and the input combination (ift_str) that produces the second output value
            - Combine truth_str and ift_str to form a bit-level implicant representing a condition under which the output changes (i.e., an IFT condition)
        Output: Set of implicants representing the IFT logic for the LUT
        """
        init_vector = lut.result[::-1]
        n = len(lut.input_names)
        implicants = set()
        size = len(init_vector)
        truth_str = ''
        ift_str = ''
        # print(f"Initial Vector: {init_vector}")
        # print(f"n: {n}, size: {size}")
        for i in range(0, size):
            for j in range(i + 1, size):
                if init_vector[i] != init_vector[j]:
                    mask = 2**(n-1)
                    addr = i
                    flipaddr = j ^ addr
                    truth_str = ''
                    ift_str = ''
                    # print(f"Mask: {mask}, Addr: {addr}, FlipAddr: {flipaddr}")
                    while mask > 0:
                        if addr & mask:
                            truth_str = truth_str + '1'
                        else:
                            truth_str = truth_str + '0'
                        if flipaddr & mask:
                            ift_str = ift_str + '1'
                        else:
                            ift_str = ift_str + '0'
                        #print(f"Truth Str: {truth_str}, IFT Str: {ift_str}")
                        mask = mask // 2
                if truth_str and ift_str:
                    # print(f"Add Implicant: {truth_str + ift_str}")
                    implicants.add(truth_str + ift_str)
        # print(f"Implicants: {sorted(implicants)}")
        self.translateImplicants(implicants)
        return implicants
    
    def translate(self, bit_implicant: str) -> str:
        """
        Translate a bit-level implicant into a variable-level expression
        Input: A string representing the bit-level implicant (e.g., "1010")
        Logic: For each bit and its corresponding taint bit:
            - If both are '1', include the original variable in the expression (e.g., "A")
            - If original is '1' and taint is '0', include the original variable (e.g., "A")
            - If original is '0' and taint is '1', include the taint variable (e.g., "A_t")
            - If both are '0', include the negation of the original variable (e.g., "~A")
        Output: A string representing the variable-level expression (e.g., "A_t & ~B")
        """
        variable_implicant = ""
        for i in range(len(bit_implicant)//2):
            original = i
            tainted = i + len(bit_implicant)//2
            if bit_implicant[original] == '1' and bit_implicant[tainted] == '1':
                variable_implicant = variable_implicant + self.input_names[original] + " & "
            elif bit_implicant[original] == '1' and bit_implicant[tainted] == '0':
                variable_implicant = variable_implicant + self.input_names[original] + " & "
            elif bit_implicant[original] == '0' and bit_implicant[tainted] == '1':
                variable_implicant = variable_implicant + self.input_names[tainted] + " & "
            else:
                variable_implicant = variable_implicant + " ~" + self.input_names[original] + " & "
        variable_implicant = variable_implicant[:-3]
        # print(f"Implicant: {bit_implicant} → variable_implicant: {variable_implicant}")
        return variable_implicant

    def translateImplicants(self, implicants: set):
        """
            Combine all variable-level implicants into a single expression representing the IFT logic for the LUT
            Input: A set of bit-level implicants
            Logic: For each implicant, translate it to a variable-level expression and combine them using OR
            Output: A string representing the combined IFT expression for the LUT
        """
        function = ""
        for implicant in implicants:
            function = function + self.translate(implicant) + " | "
        function = function[:-3]
        function = expr(function)
        return function
    

    def get_original_expression(self, lut):
        """
            Generate the original logic expression for the LUT based on its truth table
            Input: A LUT object containing the LUT's output truth table and input names
            Logic: Use the pyeda library to convert the LUT's truth table into a logic expression
            Output: A string representing the original logic expression for the LUT
        """
        out = lut.result[::-1]
        sop = truthtable(self.vars[0:len(self.vars)//2], out)
        expression = truthtable2expr(sop)
        expression = self.pretty(expression)
        return expression
        

    def pretty(self, expr)-> str:
        """
        Format a pyeda expression into a more readable string format
        Input: A pyeda expression object
        Logic: Replace variable names with user-friendly names, and format the expression using standard logical operators
        Output: A formatted string representing the logic expression
        """
        for key, value in self.output_expressions.items():
            if key in self.name_map:
                sub = self.name_map[key]
                expr = expr.compose({sub: value})
        minimal_expr, = espresso_exprs(expr)
        s = str(expr)
        minimal_s = str(minimal_expr)
        for py_var, user_var in self.name_map.items():
            s = s.replace(str(user_var), py_var)
            minimal_s = minimal_s.replace(str(user_var), py_var)
        s = s.replace('Or', '|').replace('And', '&').replace('~', '~')
        minimal_s = minimal_s.replace('Or', '|').replace('And', '&').replace('~', '~')
        # print(f"Expression before simplification: {s}")
        # print(f"Expression after simplification: {minimal_s}")
        return minimal_s
    
    def run(self):
        i = 1
        for lut in self.LUTs:
            print(f"LUT #{i}")
            implicants = self.ift_logic_generation(lut)
            function = self.translateImplicants(implicants)
            self.output_expressions[lut.output_name] = self.get_original_expression(lut)
            self.output_expressions[lut.output_name + "_t"] = self.pretty(function)
            print(f"Original Expression: {lut.output_name} = {self.output_expressions[lut.output_name]}")
            print(f"IFT Expression: {lut.output_name}_t = {self.output_expressions[lut.output_name + '_t']}")
            i = i + 1
            print("\n========================================================================================\n")

    
    
if __name__ == "__main__":
    eblif_fileName = "../examples/FA_1bit.eblif"
    ift = IFT(eblif_fileName)
    # print(f"Input Names: {ift.input_names}")
    # print(f"Output Names: {ift.output_names}")
    # print(f"Variables: {ift.vars}")
    # print(f"Name Map: {ift.name_map}")
    ift.run()
        