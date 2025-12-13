class Key:
    def __init__(self, key: str):
        self.key = key
        self.size = len(key)
        self.ones, self.zeros = self.scan()
        self.ones_addresses = [self.selection(bit, 1) for bit in self.ones]
        self.zeros_addresses = [self.selection(bit, 0) for bit in self.zeros]
        self.intersection = self.getIntersection()

    def scan(self) -> list: # Scan for the expression
        ones = []
        zeros = []
        for i in range(self.size // 2):
            if self.key[i] == '1':
                ones.append(len(self.key) - i - 1)
            elif self.key[i+self.size//2] == '1':
                ones.append(len(self.key) - (i+self.size//2) - 1)
            else:
                zeros.append(len(self.key) - i - 1)
        return ones, zeros
    
    def selection(self, bit_position: int, select: int) -> set: # Get addresses where we have '1' or '0' at bit_position
        addresses = set()
        step = 2 ** bit_position
        index = step if select == 1 else 0
        for i in range(2 ** (self.size - bit_position - 1)):
            addresses.update(range(index, index + step))
            index += 2 * step
        return addresses

    def getIntersection(self) -> list: # Get intersection of addresses for all '1' bit positions excluding the '0' bit positions
        if(not self.ones):
            return []
        addresses = self.selection(self.ones[0], 1)
        for i in range(1, len(self.ones)):
            addresses = addresses.intersection(self.selection(self.ones[i], 1))
        for i in range(len(self.zeros)):
            addresses = addresses.intersection(self.selection(self.zeros[i], 0))
        return sorted(addresses)

# if __name__ == "__main__":
#     keys = ["0101", "0110", "1001"]
#     ift = IFT(keys)
#     output_addresses = ift.getIndices()
#     print("AND:", sorted(output_addresses))
#     keys2 = ["0011", "0010", "0001"]
#     ift = IFT(keys2)
#     output_addresses = ift.getIndices()
#     print("OR:", sorted(output_addresses))

    