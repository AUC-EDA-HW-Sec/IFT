from itertools import product
from pyeda.inter import expr, exprvars, And, Or, espresso_exprs, truthtable, truthtable2expr
from EBLIF import *
from LUT import *
from Key import *

class IFT:
    def __init__(self, eblif_fileName):
        self.eblif_fileName = eblif_fileName
        self.instance_fileName = os.path.join(os.path.dirname(__file__), '..', 'out', 'top_module', self.eblif_fileName.replace('.eblif', '.v'))
        self.eblif = EBLIF(eblif_fileName)
        self.LUTs = self.eblif.LUTs
        self.input_names = self.eblif.input_names + [name + "_t" for name in self.eblif.input_names]
        self.output_names = self.eblif.output_names + [name + "_t" for name in self.eblif.output_names]
        self.input_names = [name.replace("[", "").replace("]", "") for name in self.input_names]
        self.output_names = [name.replace("[", "").replace("]", "") for name in self.output_names]
        self.vars = exprvars('v', len(self.input_names))
        self.name_map = dict(zip(self.input_names, self.vars))
        self.output_expressions = {}

        # Clear the files before appending new modules
        with open(self.instance_fileName, 'w') as f:
            pass
    

    def ift_logic_generation(self, lut: LUT) -> set:
        """
        Generate IFT logic for a given LUT
        Application of the IFT generation algorithm from "LUT Level Information Flow Tracking for FPGA Design Security Verification" by Zhang et al.

        Input: LUT object containing the LUT's output truth table and input names
            (e.g., input_names=["A", "B"], result="1000")

        Logic:
            - For each pair of output values in the LUT's truth table, identify pairs that differ (i.e., one is 0 and the other is 1)
            - For each differing pair, determine the input combination (truth_str) that produces the first output value, and the input combination (ift_str) that produces the second output value
            - Combine truth_str and ift_str to form a bit-level implicant representing a condition under which the output changes (i.e., an IFT condition)

        Output: Set of implicants representing the IFT logic for the LUT
            (e.g., {"0011", "0110", "1000"})
        """
        init_vector = lut.result[::-1]
        n = len(lut.input_names)
        implicants = set()
        size = len(init_vector)
        truth_str = ''
        ift_str = ''
        for i in range(0, size):
            for j in range(i + 1, size):
                if init_vector[i] != init_vector[j]:
                    mask = 2**(n-1)
                    addr = i
                    flipaddr = j ^ addr
                    truth_str = ''
                    ift_str = ''
                    while mask > 0:
                        if addr & mask:
                            truth_str = truth_str + '1'
                        else:
                            truth_str = truth_str + '0'
                        if flipaddr & mask:
                            ift_str = ift_str + '1'
                        else:
                            ift_str = ift_str + '0'
                        mask = mask // 2
                    if truth_str and ift_str:
                        implicants.add(truth_str + ift_str)
        self.translateImplicants(implicants)
        return implicants
    

    def translate(self, bit_implicant: str) -> str:
        """
        Translate a bit-level implicant into a variable-level expression

        Input: A string representing the bit-level implicant 
            (e.g., "1001")

        Logic: For each bit and its corresponding taint bit:
            - If the taint bit is 1, include the corresponding variable in the expression (e.g., "A_t")
            - If the taint bit is 0 and the original bit is 1, include the original variable (e.g., "A")
            - If the taint bit is 0 and the original bit is 0, include the negation of the original variable (e.g., "~A")

        Output: A string representing the variable-level expression 
            (e.g., "A & B_t")
        """
        variable_implicant = ""
        for i in range(len(bit_implicant)//2):
            original = i
            tainted = i + len(bit_implicant)//2
            if bit_implicant[tainted] == '1': # Tainted variable is 1, include the tainted variable in the expression
                variable_implicant += f"I{tainted} & "
            elif bit_implicant[original] == '1': # Tainted variable is 0 and original variable is 1, include the original variable in the expression
                variable_implicant += f"I{original} & "
            else: # Tainted variable is 0 and original variable is 0, include the negation of the original variable in the expression
                variable_implicant += f"~I{original} & "
        variable_implicant = variable_implicant[:-3]
        return variable_implicant


    def translateImplicants(self, implicants: set) -> expr:
        """
            Combine all variable-level implicants into a single expression representing the IFT logic for the LUT

            Input: A set of bit-level implicants 
                (e.g., {"0011", "0110", "1001"})

            Logic: For each implicant, translate it to a variable-level expression and combine them using OR

            Output: A string representing the combined IFT expression for the LUT
                (e.g., "Or(And(A_t, B_t), And(A, B_t), And(A_t, B))")
        """
        function = ""
        for implicant in implicants:
            function = function + self.translate(implicant) + " | "
        function = function[:-3] # Remove the trailing " | "
        function = expr(function)
        return function
    

    def get_original_expression(self, lut: LUT) -> str:
        """
            Generate the original logic expression for the LUT based on its truth table

            Input: A LUT object containing the LUT's output truth table and input names 
                (e.g., input_names=["A", "B"], result="1000")

            Logic: Use the pyeda library to convert the LUT's truth table into a logic expression 
                
            Output: A string representing the original logic expression for the LUT
                (e.g., "&(A, B)")
        """
        out = lut.result[::-1]
        input_vars = exprvars('o', len(lut.input_names))
        dictionary = dict(zip(lut.input_names[::-1], input_vars))
        sop = truthtable(input_vars, out)
        expression = truthtable2expr(sop)
        expression = str(expression)
        for var in self.vars:  # Replace pyeda variable names with user-friendly names
            expression = expression.replace("o", "I").replace("[", "").replace("]", "")
        for key, value in self.output_expressions.items(): # Substitute previously generated expressions if they are present in the current expression
            if key in expression:
                expression = expression.replace(str(key), value)
        expression = expression.replace("|", "Or").replace("&", "And")
        expression = expr(expression)
        expression = self.pretty(expression)
        return expression
        

    def pretty(self, expr: expr)-> str:
        """
        Format a pyeda expression into a more readable string format

        Input: A pyeda expression object
            (e.g., "Or(And(A_t, B), And(B_t, A_t), And(A, B_t))")

        Logic: Replace variable names with user-friendly names, and format the expression using standard logical operators

        Output: A formatted string representing the logic expression
            (e.g., "|(&(A_t, B), &(B_t, A_t), &(A, B_t))")
        """
        for key, value in self.output_expressions.items(): # Substitute previously generated expressions if they are present in the current expression
            if key in self.name_map:
                sub = self.name_map[key]
                expr = expr.compose({sub: value})
        expr = expr.to_dnf() # Convert the expression to Disjunctive Normal Form to simplify it before minimizing
        minimal_expr, = espresso_exprs(expr) # Minimize the expression
        minimal_s = str(minimal_expr)
        for var in self.vars:  # Replace pyeda variable names with user-friendly names
            if str(var) in minimal_s:
                minimal_s = minimal_s.replace(str(var), str(var).replace("v", "I")).replace("[", "").replace("]", "")
        minimal_s = minimal_s.replace('Or', '|').replace('And', '&').replace('~', '~')
        return minimal_s
    

    def to_verilog_expression(self, expr: str) -> str:
        """
        Convert a pyeda expression into a Verilog-compatible string format

        Input: A pretty-printed expression string from the pyeda library 
            (e.g., "|(&(B_t, A_t), &(A_t, ~B), &(~A, B_t))")

        Logic: Replace logical operators with their Verilog equivalents, and format the expression accordingly 

        Output: A string representing the logic expression in Verilog syntax 
            (e.g., "B_t & A_t | A_t & ~B | ~A & B_t")
        """
        verilog_expr = expr
        if verilog_expr[0] == '|': # If the expression is a Sum of Products (SOP), split them and format each term separately
            verilog_expr = verilog_expr.strip("|")
            verilog_expr = verilog_expr[1:-1]
            verilog_expr = verilog_expr.split("&")
            verilog_expr = [item for item in verilog_expr if item]
            verilog_expr = [item.replace("), ", ")") for item in verilog_expr]
            if len(verilog_expr) > 1: # If there are multiple terms, replace the AND operator with the Verilog equivalent and join them with OR
                verilog_expr = [item.replace(", ", " & ") for item in verilog_expr]
                verilog_expr = " \n\t\t| ".join(verilog_expr)
            else: # If there are no AND operators, just replace the OR operator with the Verilog equivalent
                verilog_expr = verilog_expr[0].replace(", ", " | ")
        else: # If the expression is a single AND term, just replace the AND operator with the Verilog equivalent
            verilog_expr = verilog_expr[2:-1]
            verilog_expr = verilog_expr.replace(", ", " & ")
        return verilog_expr
    

    def to_verilog_module(self, lut_output: str, original_output: str, ift_output: str) -> None:
        """
        Generate a Verilog file containing the original and IFT expressions for a given LUT

        Input: The output name of the LUT, the original expression, and the IFT expression

        Output: A Verilog file written to the output directory, containing a module with the original and IFT logic for each LUT
            (e.g., "module LUT_3(
                        input A, B, A_t, B_t,
                        output O, O_t
                    );
                    
                        assign O = A & ~B | ~A & B;
                        
                        assign O_t = B_t & A_t | A_t & ~B | ~A & B_t;
                    endmodule"
                )
        """
        path = os.path.join(os.path.dirname(__file__), '..', 'out', 'LUTLIFT_lib', f"LUT_{lut_output}.v")
        if os.path.exists(path):
            return
        with open(path, 'a') as f:
            f.write(f"module LUT_{lut_output}(\n")
            f.write("\tinput ")
            for i in range(len(self.input_names)):
                f.write(f"I{i}, ")
            f.write("\n")
            f.write(f"\toutput O, O_t\n")
            f.write(");\n\n")
            verilog_original_expr = self.to_verilog_expression(self.output_expressions[original_output])
            verilog_ift_expr = self.to_verilog_expression(self.output_expressions[ift_output])
            f.write(f"\tassign O = {verilog_original_expr};\n\n")
            f.write(f"\tassign O_t = {verilog_ift_expr};\n\n")
            f.write("endmodule\n")
            f.write("\n\n" + "//" + "="*80 + "\n\n")
        return
    
    

    def run(self) -> None:
        count = 1
        with open(self.instance_fileName, 'a') as f:
            f.write(f"module {self.eblif_fileName.replace('.eblif', '')}(\n")
            f.write("\tinput ")
            for input_name in self.input_names:
                f.write(f"{input_name}, ")
            f.write("\n")
            f.write(f"\toutput ")
            for i in range(len(self.output_names) - 1):
                f.write(f"{self.output_names[i]}, ")
            f.write(f"{self.output_names[-1]}\n")
            f.write(");\n\n")

        for lut in self.LUTs:
            hexa = hex(int(lut.result, 2)).replace("0x", "")
            implicants = self.ift_logic_generation(lut)
            function = self.translateImplicants(implicants)
            self.output_expressions[lut.output_name] = self.get_original_expression(lut)
            self.output_expressions[lut.output_name + "_t"] = self.pretty(function)
            print(f"Original Expression: {lut.output_name} = {self.output_expressions[lut.output_name]}")
            print(f"IFT Expression: {lut.output_name}_t = {self.output_expressions[lut.output_name + '_t']}")
            self.to_verilog_module(hexa, lut.output_name, lut.output_name + "_t")

            with open(self.instance_fileName, 'a') as f:
                f.write(f"\tLUT_{hexa} LUT_{count}(\n")
                for i in range(len(self.input_names)):
                    f.write(f"\t\t.I{i}({self.input_names[i]}),\n")
                f.write(f"\t\t.O({lut.output_name}),\n")
                f.write(f"\t\t.O_t({lut.output_name}_t)\n")
                f.write("\t);\n\n")

            count = count + 1
            print("\n========================================================================================\n")
        
        with open(self.instance_fileName, 'a') as f:
            f.write("endmodule\n")

    
    
if __name__ == "__main__":
    eblif_fileName = "and.eblif"
    ift = IFT(eblif_fileName)
    ift.run()
        