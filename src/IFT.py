from itertools import product
from pyeda.inter import expr, exprvars, And, Or, espresso_exprs, truthtable, truthtable2expr
from EBLIF import *
from LUT import *
from Key import *

class IFT:
    def __init__(self, eblif_fileName):
        self.eblif_fileName = eblif_fileName
        self.eblif = EBLIF(eblif_fileName)
        self.LUTs = self.eblif.LUTs
        self.input_names = self.eblif.input_names + [name + "_t" for name in self.eblif.input_names]
        self.output_names = self.eblif.output_names + [name + "_t" for name in self.eblif.output_names]
        self.input_names = [name.replace("[", "").replace("]", "") for name in self.input_names]
        self.output_names = [name.replace("[", "").replace("]", "") for name in self.output_names]
        self.vars = exprvars('v', len(self.input_names))
        self.name_map = dict(zip(self.input_names, self.vars))
        self.number_of_LUTs = len(self.LUTs)
        self.output_expressions = {}
    
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
                    #print(f"Mask: {mask}, Addr: {addr}, FlipAddr: {flipaddr}")
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
            if bit_implicant[tainted] == '1':
                variable_implicant += self.input_names[tainted] + " & "
            elif bit_implicant[original] == '1':
                variable_implicant += self.input_names[original] + " & "
            else:
                variable_implicant += "~" + self.input_names[original] + " & "
        variable_implicant = variable_implicant[:-3]
        # print(f"Implicant: {bit_implicant} → variable_implicant: {variable_implicant}")
        return variable_implicant

    def translateImplicants(self, implicants: set) -> expr:
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
        # print(f"LUT input names: {lut.input_names}")
        # print(f"Name Map: {self.name_map}")
        input_vars = exprvars('o', len(lut.input_names))
        dictionary = dict(zip(lut.input_names[::-1], input_vars))
        # print(f"Input Variables: {input_vars}")
        sop = truthtable(input_vars, out)
        print(f"Original Truth Table: {sop}")
        expression = truthtable2expr(sop)
        expression = str(expression)
        for key, value in dictionary.items():
            expression = expression.replace(str(value), key)
        # print(f"Original Expression: {expression}")
        # print(f"Expression after variable substitution: {expression}")
        for key, value in self.output_expressions.items():
            if key in expression:
                # print(f"Substituting {key} with {value} in expression: {expression}")
                expression = expression.replace(str(key), value)
        expression = expression.replace("|", "Or").replace("&", "And")
        # print(f"Expression after output substitution: {expression}")
        expression = expr(expression)
        expression = self.pretty(expression)
        # print(f"Final Original Expression: {expression}")
        return expression
        

    def pretty(self, expr: expr)-> str:
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
        expr = expr.to_dnf()
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
    
    def to_verilog_expression(self, expr: str) -> str:
        """
        Convert a pyeda expression into a Verilog-compatible string format
        Input: A pretty-printed expression string from the pyeda library
        Logic: Replace logical operators with their Verilog equivalents, and format the expression accordingly
        Output: A string representing the logic expression in Verilog syntax
        """
        verilog_expr = expr
        if verilog_expr[0] == '|':
            verilog_expr = verilog_expr.strip("|")
            verilog_expr = verilog_expr[1:-1]
            verilog_expr = verilog_expr.split("&")
            verilog_expr = [item for item in verilog_expr if item]
            verilog_expr = [item.replace("), ", ")") for item in verilog_expr]
            if len(verilog_expr) > 1:
                verilog_expr = [item.replace(", ", " & ") for item in verilog_expr]
                verilog_expr = " \n\t\t| ".join(verilog_expr)
            else:
                verilog_expr = verilog_expr[0].replace(", ", " | ")
        else:
            verilog_expr = verilog_expr[2:-1]
            verilog_expr = verilog_expr.replace(", ", " & ")
            print(f"Single term AND: {verilog_expr}")
        return verilog_expr
    
    def to_verilog_file(self, lut_output: str, original_output: str, ift_output: str):
        """
        Generate a Verilog file containing the original and IFT expressions for a given LUT
        Input: The output name of the LUT, the original expression, and the IFT expression
        Output: A Verilog file written to the output directory, containing a module with the original and IFT logic for each LUT
        """
        out_dir = os.path.join(os.path.dirname(__file__), '..', 'out')
        file_name = os.path.join(out_dir, self.eblif_fileName.replace('.eblif', '.v'))
        with open(file_name, 'a') as f:
            f.write(f"module LUT_{lut_output}(\n")
            f.write("\tinput ")
            for input_name in self.input_names:
                f.write(f"{input_name}, ")
            f.write("\n")
            f.write(f"\toutput {original_output}, {ift_output}\n")
            f.write(");\n\n")
            verilog_original_expr = self.to_verilog_expression(self.output_expressions[original_output])
            verilog_ift_expr = self.to_verilog_expression(self.output_expressions[ift_output])
            f.write(f"\tassign {original_output} = {verilog_original_expr};\n\n")
            f.write(f"\tassign {ift_output} = {verilog_ift_expr};\n\n")
            f.write("endmodule\n")
            f.write("\n\n" + "//" + "="*80 + "\n\n")
        return


    def run(self):
        i = 1
        for lut in self.LUTs:
            print(f"LUT #{i}")
            hexa = hex(int(lut.result, 2)).replace("0x", "")
            implicants = self.ift_logic_generation(lut)
            # print(f"Implicants: {sorted(implicants)}")
            function = self.translateImplicants(implicants)
            print(f"Generated IFT Expression: {function}, type: {type(function)}")
            self.output_expressions[lut.output_name] = self.get_original_expression(lut)
            self.output_expressions[lut.output_name + "_t"] = self.pretty(function)
            print(f"Original Expression: {lut.output_name} = {self.output_expressions[lut.output_name]}")
            print(f"IFT Expression: {lut.output_name}_t = {self.output_expressions[lut.output_name + '_t']}")
            self.to_verilog_file(hexa, lut.output_name, lut.output_name + "_t")

            i = i + 1
            print("\n========================================================================================\n")

    
    
if __name__ == "__main__":
    eblif_fileName = "and.eblif"
    ift = IFT(eblif_fileName)
    ift.run()
        