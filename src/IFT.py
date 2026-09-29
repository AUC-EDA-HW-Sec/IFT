import os
import subprocess
import shutil
from itertools import product
from unittest import result
import os
import subprocess
import re
import keyword
from pyeda.inter import expr, exprvars, And, Or, espresso_exprs, truthtable, truthtable2expr
from EBLIF import *
from LUT import *
from Key import *

class IFT:
    def __init__(self, eblif_fileName):
        self.eblif_fileName = eblif_fileName
        
        self.base_out_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'out', f"{self.eblif_fileName.replace('.eblif', '')}"))
        self.top_mod_dir = os.path.join(self.base_out_dir, 'top_module')
        self.lut_lib_dir = os.path.join(self.base_out_dir, 'LUTLIFT_lib')
        self.default_luts_dir = os.path.join(self.base_out_dir, 'default_LUTs')
        self.sby_dir = os.path.join(self.base_out_dir, 'sby')
        self.eblif_dir = os.path.join(self.base_out_dir, 'eblif')
        self.source_default_luts_dir = os.path.join(os.path.dirname(self.base_out_dir), 'default_LUTs')
        self.eblif_source_path = os.path.join(os.path.dirname(__file__), '..', 'examples', self.eblif_fileName)
        self.eblif_copy_path = os.path.join(self.eblif_dir, os.path.basename(self.eblif_fileName))
        
        # Ensure directories exist right away
        os.makedirs(self.top_mod_dir, exist_ok=True)
        os.makedirs(self.lut_lib_dir, exist_ok=True)
        shutil.copytree(self.source_default_luts_dir, self.default_luts_dir, dirs_exist_ok=True)
        os.makedirs(self.sby_dir, exist_ok=True)
        os.makedirs(self.eblif_dir, exist_ok=True)
        shutil.copy2(self.eblif_source_path, self.eblif_copy_path)
        
        self.instance_fileName = os.path.join(self.top_mod_dir, self.eblif_fileName.replace('.eblif', '.v'))
        
        self.eblif = EBLIF(eblif_fileName)
        self.LUTs = self.eblif.LUTs
        
        self.original_inputs = [name.replace("[", "").replace("]", "") for name in self.eblif.input_names]
        self.original_outputs = [name.replace("[", "").replace("]", "") for name in self.eblif.output_names]
        
        self.input_names = self.original_inputs + [name + "_t" for name in self.original_inputs]
        self.output_names = self.original_outputs + [name + "_t" for name in self.original_outputs]
        
        self.vars = exprvars('v', len(self.input_names))
        self.name_map = dict(zip(self.input_names, self.vars))
        self.output_expressions = {}

        # Reset target top module output file
        with open(self.instance_fileName, 'w') as f:
            pass


    def verilog_safe_name(self, name: str) -> str:
        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", name) and not keyword.iskeyword(name):
            return name
        return f"{name}_top"


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


    def translateImplicants(self, implicants: set):
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
        

    def pretty(self, expr)-> str:
        """
        Format a pyeda expression into a more readable string format

        Input: A pyeda expression object
            (e.g., "Or(And(A_t, B), And(B_t, A_t), And(A, B_t))")

        Logic: Replace variable names with user-friendly names, and format the expression using standard logical operators

        Output: A formatted string representing the logic expression
            (e.g., "|(&(A_t, B), &(B_t, A_t), &(A, B_t))")
        """
        # for key, value in self.output_expressions.items(): # Substitute previously generated expressions if they are present in the current expression
        #     if key in self.name_map:
        #         sub = self.name_map[key]
        #         expr = expr.compose({sub: value})
        expr = expr.to_dnf() # Convert the expression to Disjunctive Normal Form to simplify it before minimizing
        # expr_s = str(expr)
        # for var in self.vars:  # Replace pyeda variable names with user-friendly names
        #     if str(var) in expr_s:
        #         expr_s = expr_s.replace(str(var), str(var).replace("v", "I")).replace("[", "").replace("]", "")
        # expr_s = expr_s.replace('Or', '|').replace('And', '&').replace('~', '~')
        minimal_expr, = espresso_exprs(expr) # Minimize the expression
        minimal_s = str(minimal_expr)
        for var in self.vars:  # Replace pyeda variable names with user-friendly names
            if str(var) in minimal_s:
                minimal_s = minimal_s.replace(str(var), str(var).replace("v", "I")).replace("[", "").replace("]", "")
        minimal_s = minimal_s.replace('Or', '|').replace('And', '&').replace('~', '~')
        return minimal_s
        # return expr_s
    

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
    

    def to_verilog_module(self, lut_output: str, ift_output: str) -> str:
        """
        Generate a Verilog file containing the original and IFT expressions for a given LUT

        Input: The output name of the LUT, the original expression, and the IFT expression

        Output: A Verilog file written to the output directory, containing a module with the original and IFT logic for each LUT
            (e.g., "module LUT_3(
                        input A, B, A_t, B_t,
                        output O_t
                    );
                                            
                        assign O_t = B_t & A_t | A_t & ~B | ~A & B_t;

                    endmodule"
                )
        """
        path = os.path.join(self.lut_lib_dir, f"LUT_{lut_output}.v")
        if os.path.exists(path):
            with open(path, 'r') as f:
                content = f.read()
                if f"module LUT_{lut_output}(" in content:
                    return content
            return ""
        else:
            content = ""
            content += f"module LUT_{lut_output}(\n"
            content += "\tinput "
            for i in range(len(self.input_names)):
                content += f"I{i}, "
            content += "\n"
            content += f"\toutput O_t\n"
            content += ");\n\n"
            verilog_ift_expr = self.to_verilog_expression(self.output_expressions[ift_output])
            content += f"\tassign O_t = {verilog_ift_expr};\n\n"
            content += "endmodule\n"
            
            with open(path, 'a') as f:
                f.write(content)
        return content
    
    

    def generate_top_module(self):
        print("================================ IFT GENERATION ================================\n")
        # Write the original and IFT modules for each LUT to the output directory
        default_lut_module = [False] * 6
        i = 1
        module_name = self.verilog_safe_name(self.eblif_fileName.replace('.eblif', ''))
        for lut in self.LUTs:
            lut_inputs = int(len(lut.input_names))
            lut_length = int(2**(lut_inputs))
            lut_module = ""
            hexa = hex(int(lut.result, 2)).replace("0x", "")
            print(f"LUT #{i}: {lut.output_name} (hexa: {hexa})")
            print(f"   - {lut_inputs} Inputs: {', '.join(lut.input_names)}")
            implicants = self.ift_logic_generation(lut)
            function = self.translateImplicants(implicants)
            self.output_expressions[lut.output_name] = self.get_original_expression(lut)
            self.output_expressions[lut.output_name + "_t"] = self.pretty(function)
            print(f"   - {lut.output_name} = {self.output_expressions[lut.output_name]}")
            print(f"   - {lut.output_name}_t = {self.output_expressions[lut.output_name + '_t']}\n")
            # print("" + "-" * 80 + "\n")
            tainted = self.to_verilog_module(hexa, lut.output_name + "_t")
            if not default_lut_module[lut_inputs]:
                with open(os.path.join(self.default_luts_dir, f"LUT{lut_inputs}.v"), 'r') as f:                    
                    lut_module = f.read()
                default_lut_module[lut_inputs] = True
            with open(self.instance_fileName, 'a') as f:
                if lut_module:
                    f.write(lut_module)
                    f.write("\n\n" + "//" + "=" * 80 + "\n\n")
                f.write(tainted)
                f.write("\n\n" + "//" + "=" * 80 + "\n\n")
            i += 1
                

        # Write the top module header
        count = 1
        with open(self.instance_fileName, 'a') as f:
            f.write(f"module {module_name}(\n")
            f.write("\tinput ")
            for input_name in self.input_names:
                f.write(f"{input_name}, ")
            f.write("\n")
            f.write(f"\toutput wire ")
            for i in range(len(self.output_names) - 1):
                f.write(f"{self.output_names[i]}_output, ")
            f.write(f"{self.output_names[-1]}_output\n")
            f.write(");\n\n")

            f.write(f"\twire ")
            for i in range(len(self.output_names) - 1):
                f.write(f"{self.output_names[i]}, ")
            f.write(f"{self.output_names[-1]};\n\n")
            for output_name in self.output_names:
                f.write(f"\tassign {output_name}_output = {output_name};\n")
            f.write("\n")


        # Generate IFT logic for each LUT and write the corresponding Verilog instantiations
        for lut in self.LUTs:
            hexa = hex(int(lut.result, 2)).replace("0x", "")
            lut_inputs = int(len(lut.input_names))
            lut_length = int(2**(lut_inputs))

            with open(self.instance_fileName, 'a') as f:
                # Write the original LUT module instantiation using standart LUT primitive
                f.write(f"\tLUT{lut_inputs} #(.INIT({lut_length}'b{lut.result})) LUT_{count} (\n")
                for i in range(lut_inputs):
                    f.write(f"\t\t.I{i}({lut.input_names[i]}),\n")
                f.write(f"\t\t.O({lut.output_name})\n")
                f.write("\t);\n\n")

                # Write the IFT LUT module instantiation using the generated IFT module
                f.write(f"\tLUT_{hexa} LUT_{count}_t(\n")
                for i in range(len(lut.input_names)):
                    f.write(f"\t\t.I{i}({lut.input_names[i]}),\n")
                f.write(f"\t\t.O_t({lut.output_name}_t)\n")
                f.write("\t);\n\n")
            count = count + 1
        
        # Write the formal assertions to the top module to ensure that taint does not reach any primary output
        with open(self.instance_fileName, 'a') as f:
            f.write("\n`ifdef FORMAL\n")
            f.write("\talways @(*) begin\n")
            
            for target_input in self.original_inputs:
                f.write(f"\t\t`ifdef TAINT_{target_input}\n")
                f.write(f"\t\t\tassume ({target_input}_t == 1'b1);\n")
                for other_input in self.original_inputs:
                    if other_input != target_input:
                        f.write(f"\t\t\tassume ({other_input}_t == 1'b0);\n")
                f.write("\t\t`endif\n")
            
            f.write("\n\t\t// Isolated Output Assertions\n")
            for out_name in self.original_outputs:
                f.write(f"\t\t`ifdef CHECK_{out_name}\n")
                f.write(f"\t\t\tassert ({out_name}_t == 1'b0);\n")
                f.write("\t\t`endif\n")
                
            f.write("\tend\n")
            f.write("`endif\n\n")
            f.write("endmodule\n\n")
        return 
  
    def generate_openfpga_task(self):
        import glob
        import os
        import shutil
        import subprocess
        import time

        openfpga_task_name = "my_adder_task"
        module_name = self.verilog_safe_name(self.eblif_fileName.replace(".eblif", ""))
        openfpga_path = os.getenv("OPENFPGA_PATH", os.path.expanduser("~/OpenFPGA"))
        task_dir = os.path.join(openfpga_path, "openfpga_flow", "tasks", openfpga_task_name)
        task_file = os.path.join(task_dir, "config", "task.conf")
        final_out_dir = os.path.join(self.base_out_dir, "openfpga_tasks")
        os.makedirs(final_out_dir, exist_ok=True)
        task_benchmark_file = os.path.join(task_dir, f"{module_name}.v")

        task_content = f"""[GENERAL]
run_engine=openfpga_shell
power_tech_file = ${{PATH:OPENFPGA_PATH}}/openfpga_flow/tech/PTM_45nm/45nm.xml
power_analysis = true
spice_output=false
verilog_output=true
timeout_each_job = 20*60
# Switch back to yosys_vpr
fpga_flow=yosys_vpr

[OpenFPGA_SHELL]
openfpga_shell_template=${{PATH:OPENFPGA_PATH}}/openfpga_flow/openfpga_shell_scripts/write_full_testbench_example_script.openfpga
openfpga_arch_file=${{PATH:OPENFPGA_PATH}}/openfpga_flow/openfpga_arch/k4_N4_40nm_cc_openfpga.xml
openfpga_sim_setting_file=${{PATH:OPENFPGA_PATH}}/openfpga_flow/openfpga_simulation_settings/auto_sim_openfpga.xml
openfpga_vpr_device_layout=
openfpga_fast_configuration=

[ARCHITECTURES]
arch0=${{PATH:OPENFPGA_PATH}}/openfpga_flow/vpr_arch/k4_N4_tileable_40nm.xml

[BENCHMARKS]
# Point to your Verilog file
bench0=${{PATH:TASK_DIR}}/{module_name}.v

[SYNTH_BENCHMARKS]
# Update top module name
bench0_top={module_name}

[SYNTHESIS_PARAM]
bench_read_verilog_options_common = -nolatches
# Update top module name
bench0_top = {module_name}
bench0_chan_width = 300

[SCRIPT_PARAM_MIN_ROUTE_CHAN_WIDTH]
end_flow_with_test=

[VARIABLES]
# Update top module name
top_module={module_name}
# Point to your Verilog file
circuit_file=${{PATH:TASK_DIR}}/{module_name}.v
"""

        print("=============================== OpenFPGA TASK ==============================\n")
        # print(f"Updating task file: {task_file}")
        # print(f"Using design name: {module_name}")

        try:
            if os.path.exists(task_benchmark_file):
                os.remove(task_benchmark_file)
            shutil.copyfile(self.instance_fileName, task_benchmark_file)
            # print(f"Copied benchmark Verilog to: {task_benchmark_file}")

            with open(task_file, "w", encoding="utf-8") as task_handle:
                task_handle.write(task_content)

            env = os.environ.copy()
            env["OPENFPGA_PATH"] = openfpga_path

            python_bin = "python3"
            run_task_script = os.path.join(openfpga_path, "openfpga_flow", "scripts", "run_fpga_task.py")

            # print(f"Running cleanup command for task {openfpga_task_name}...")
            subprocess.run(
                [python_bin, run_task_script, openfpga_task_name, "--remove_run_dir", "all"],
                cwd=openfpga_path,
                env=env,
                check=True,
            )

            # print(f"Running OpenFPGA task for {openfpga_task_name}...")
            run_process = subprocess.Popen(
                [python_bin, run_task_script, openfpga_task_name],
                cwd=openfpga_path,
                env=env,
            )

            generated_blif = os.path.join(
                task_dir,
                "run001",
                "k4_N4_tileable_40nm",
                module_name,
                "MIN_ROUTE_CHAN_WIDTH",
                f"{module_name}.blif",
            )

            deadline = time.time() + 300
            while time.time() < deadline:
                if os.path.exists(generated_blif):
                    break

                candidates = glob.glob(
                    os.path.join(
                        task_dir,
                        "run*",
                        "k4_N4_tileable_40nm",
                        module_name,
                        "MIN_ROUTE_CHAN_WIDTH",
                        f"{module_name}.blif",
                    )
                )
                if candidates:
                    generated_blif = max(candidates, key=os.path.getmtime)
                    if os.path.exists(generated_blif):
                        break

                if run_process.poll() is not None:
                    break

                time.sleep(1)

            if not os.path.exists(generated_blif):
                print(f"[WARNING] Could not find generated BLIF for {module_name}.")
                if run_process.poll() is None:
                    run_process.terminate()
                    try:
                        run_process.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        run_process.kill()
                        run_process.wait()
                return

            dst_path = os.path.join(final_out_dir, f"{module_name}.blif")
            if os.path.exists(dst_path):
                os.remove(dst_path)
            shutil.copyfile(generated_blif, dst_path)
            print(f"Copied BLIF to: {dst_path}")

            if run_process.poll() is None:
                run_process.terminate()
                try:
                    run_process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    run_process.kill()
                    run_process.wait()

        except FileNotFoundError as e:
            print(f"Execution failed: {e}.")
        except subprocess.CalledProcessError as e:
            print(f"OpenFPGA command failed with exit code {e.returncode}.")
        except Exception as e:
            print(f"An unexpected error occurred during execution: {e}")

            
    def run(self):
            self.generate_top_module()
            print("Generated top module")
            
            module_name = self.verilog_safe_name(self.eblif_fileName.replace('.eblif', ''))
            sby_filename = f"{module_name}.sby"
            sby_path = os.path.join(self.sby_dir, sby_filename)

            with open(sby_path, 'w') as f:
                f.write("[tasks]\n")

                for target_input, target_output in product(self.original_inputs, self.original_outputs):
                    f.write(f"check_{target_input}_to_{target_output}\n")
                    
                f.write("\n[options]\nmode bmc\ndepth 2\n\n[engines]\nsmtbmc\n\n[script]\n")
                for target_input, target_output in product(self.original_inputs, self.original_outputs):
                    f.write(f"check_{target_input}_to_{target_output}: read -formal -DTAINT_{target_input} -DCHECK_{target_output} {module_name}.v\n")
                f.write(f"prep -top {module_name}\n\n[files]\n{self.instance_fileName}\n")

            try:
                print(f"Running SymbiYosys verification for {module_name}")
                result = subprocess.run(
                    ["sby", "-f", sby_filename], 
                    cwd=self.sby_dir,
                    capture_output=True, 
                    text=True
                )
                
                print("\n=========================== IFT VERIFICATION RESULTS ===========================\n")
                for line in result.stdout.splitlines():
                    if "DONE" in line:
                        print(line)
                
                has_failures = False
                i = 1
                print("\n")

                for target_input, target_output in product(self.original_inputs, self.original_outputs):
                    task_folder = f"{module_name}_check_{target_input}_to_{target_output}"
                    task_dir = os.path.join(self.sby_dir, task_folder)
                    tb_path = os.path.join(task_dir, "engine_0", "trace_tb.v")
                    
                    if os.path.exists(tb_path):
                        has_failures = True
                        print(f"{i}: Task 'check_{target_input}_to_{target_output}' failed for:")
                        i += 1
                        # Output the assignments causing this pathway to leak
                        try:
                            with open(tb_path, 'r') as tb_f:
                                for tb_line in tb_f:
                                    if ("=" in tb_line or "<=" in tb_line) and not any(k in tb_line for k in ["initial", "begin", "clk", "clock", "cycle"]):
                                        print(f"\t{tb_line.strip().replace(';', '').replace('PI_', '')}")
                            print("\n")
                        except Exception:
                            pass
                            
                if not has_failures:
                    print("Secure layout. No information flows out directly to any primary output ports.\n")
                
                if result.stderr:
                    print("\n[ENGINE ERROR LOGS]:\n", result.stderr)
            except FileNotFoundError:
                print("[ERROR] SymbiYosys ('sby') not found in PATH.")

            self.generate_openfpga_task()


if __name__ == "__main__":
    eblif_fileName = "FA_1bit.eblif"
    ift = IFT(eblif_fileName)
    ift.run()