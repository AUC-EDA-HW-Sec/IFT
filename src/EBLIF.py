from LUT import LUT

class EBLIF:
    def __init__(self, fileName: str):
        self.fileName = fileName
        self.LUTs = []
        self.variables = []
        self.parseFile()

    def parseFile(self) -> list: # parses the EBLIF file to extract LUTs
        with open(self.fileName, 'r') as file:
            for line in file:
                if line.startswith(".inputs"):
                    inputs = line.strip().split()[1:]
                    self.variables = inputs
                elif line.startswith(".subckt lut"):
                    subckt = line.strip()
                    try:
                        param = next(file).strip()
                    except StopIteration:
                        param = None
                    lut = LUT(subckt, param)
                    self.LUTs.append(lut)
                    self.variables.append(lut.output_name)
        return self.LUTs
    
if __name__ == "__main__":
    eblif = EBLIF("FA_1bit.eblif")
    for lut in eblif.LUTs:
        print("LUT Inputs:", lut.input_names)
        print("LUT Output:", lut.output_names)
        print("LUT Output Truth Table:", lut.result)
            

    