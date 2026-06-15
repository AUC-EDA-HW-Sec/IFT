from LUT import LUT
import os

class EBLIF:
    def __init__(self, fileName: str):
        self.fileName = fileName
        self.LUTs = []
        self.input_names = []
        self.output_names = []
        self.parseFile()

    def parseFile(self) -> list: # parses the EBLIF file to extract LUTs
        examples_dir = os.path.join(os.path.dirname(__file__), '..', 'examples', self.fileName)
        with open(examples_dir, 'r') as file:
            for line in file:
                if line.startswith(".inputs"):
                    inputs = line.strip().split()[1:]
                    self.input_names.extend(inputs)
                elif line.startswith(".subckt lut"):
                    subckt = line.strip()
                    try:
                        param = next(file).strip()
                    except StopIteration:
                        param = None
                    lut = LUT(subckt, param)
                    self.LUTs.append(lut)
                    self.output_names.extend([lut.output_name])
        return self.LUTs
    
if __name__ == "__main__":
    eblif = EBLIF("FA_1bit.eblif")
    for lut in eblif.LUTs:
        print("LUT Inputs:", lut.input_names)
        print("LUT Output:", lut.output_name)
        print("LUT Output Truth Table:", lut.result)
            

    