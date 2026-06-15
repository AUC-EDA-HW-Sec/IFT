class LUT:
    def __init__(self, subckt: str, param: str):
        self.subckt = subckt
        self.param = param
        self.getInputNames()
        self.getOutputName()
        self.getOutput()
        self.getFalseInputs()
        self.getReducedTruthTable()

    def getInputNames(self)-> list: # parses the input names from the .subckt line
        self.input_names = self.subckt.split()[2:-1]
        self.input_names = [self.input_names[i].split('=')[1] for i in range(len(self.input_names))]
        self.input_names = [name.replace("[", "").replace("]", "") for name in self.input_names]
        return self.input_names
    
    def getOutputName(self)-> str: # parses the output name from the .subckt line
        self.output_name = self.subckt.split()[-1]
        self.output_name = self.output_name.split("=")[1].replace("[", "").replace("]", "")
        return self.output_name
    
    def getOutput(self)-> list: # parses the LUT output from the .param line
        self.outputs = self.param.split()[2:]
        self.outputs = list(self.outputs[0])
        return self.outputs

    def getFalseInputs(self): # identifies which inputs are tied to $false
        self.inputs = []
        for i in range(len(self.input_names)):
            if self.input_names[i] == "$false":
                self.inputs.append(0) # 0 for false
            else:
                self.inputs.append(1) # 1 otherwise
        self.input_names = [name for name in self.input_names if name != "$false"]
        self.input_names.reverse()
        return self.inputs
    
    def getReducedTruthTable(self)-> str: # removes the inputs tied to $false from the truth table
        indices_removed = [i for i, item in enumerate(self.inputs) if item == 0] # indices of inputs to be removed
        for i in range(len(indices_removed)): # for each input to be removed
            start = 0
            for j in range(len(self.outputs)//(2**indices_removed[i]*2)): # for each block of outputs (LUT size / 2^(index of input being removed + 1))
                self.outputs[start:start + 2**indices_removed[i]] = "x" * (2**indices_removed[i]) # replace first half with 'x's
                start += 2**indices_removed[i] * 2 # move to the next block
        self.result = "".join(self.outputs) # join the list into a string
        self.result = self.result.replace("x", "") # remove all 'x's
        return self.result
    