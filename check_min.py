import itertools
import sys

sys.path.insert(0, "src")
from IFT import IFT
from pyeda.inter import exprvar

job = IFT("FA_2bit/outputs/eblif/FA_2bit.eblif")
lut = job.LUTs[0]
variables = [exprvar("I" + str(index)) for index in range(6)]
raw = job.translateImplicants(job.ift_logic_generation(lut))
on_set = {
    bits
    for bits in itertools.product((0, 1), repeat=6)
    if raw.restrict(dict(zip(variables, bits))).is_one()
}
all_cubes = list(itertools.product("01-", repeat=6))

def covered(cube):
    return {
        bits for bits in on_set
        if all(value == "-" or int(value) == bits[index] for index, value in enumerate(cube))
    }

def assignments(cube):
    return {
        bits for bits in itertools.product((0, 1), repeat=6)
        if all(value == "-" or int(value) == bits[index] for index, value in enumerate(cube))
    }

valid = [cube for cube in all_cubes if assignments(cube) and assignments(cube) <= on_set]
primes = []
for cube in valid:
    can_expand = False
    for index, value in enumerate(cube):
        if value == "-":
            continue
        expanded = tuple("-" if position == index else other for position, other in enumerate(cube))
        if expanded in valid and covered(cube) < covered(expanded):
            can_expand = True
            break
    if not can_expand:
        primes.append(cube)

for term_count in range(1, len(primes) + 1):
    solutions = [
        solution for solution in itertools.combinations(primes, term_count)
        if set().union(*(covered(cube) for cube in solution)) == on_set
    ]
    if solutions:
        best = min(solutions, key=lambda solution: sum(value != "-" for cube in solution for value in cube))
        print("on_set", len(on_set))
        print("prime_implicants", len(primes))
        print("minimum_terms", term_count)
        print("minimum_literals", sum(value != "-" for cube in best for value in cube))
        print("cover", " + ".join("".join(cube) for cube in best))
        break
