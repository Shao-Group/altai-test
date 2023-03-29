# randomly select one from  bedtools intersect -wa -wb output
# assume column 1-9 is gtf and column 10+ is vcf

from sys import argv
import random

random.seed(1)

cur_exon = (-1,-1,-1)
candidate_variations = set()
printed_vars = set()


with open(argv[1], 'r') as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith("#"):
                continue
            else:
                x = line.split('\t')
                if x[2] != "exon":
                        continue 
                exon = (x[0], x[3], x[4])
                if exon == cur_exon:
                    candidate_variations.add(tuple(x[9:]))
                else:
                    if len(candidate_variations) != 0:
                        chosen = random.choice(list(candidate_variations))
                        if (chosen[0], chosen[1]) not in printed_vars:
                            printed_vars.add((chosen[0], chosen[1]))
                            print('\t'.join(chosen))
                    cur_exon = exon
                    candidate_variations = set()
                    candidate_variations.add(tuple(x[9:]))

chosen = random.choice(list(candidate_variations))
if (chosen[0], chosen[1]) not in printed_vars:
    print('\t'.join(chosen))

