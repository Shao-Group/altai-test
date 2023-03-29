# change chr name and select main chr
from sys import argv
import sys

genome = argv[1]
chr_list = argv [2]
output_prefix = argv[3]
    

# get chr dict for name change
chr_dict = dict()
with open(chr_list, 'r') as f1:
    for line in f1.readlines():
        l = line.strip().split("\t")
        if len(l) != 2:
            continue
        else:
            assert l[0] not in chr_dict
            chr_dict[l[0]] = l[1]

print(chr_dict, file=sys.stderr)


to_save = False
f3 = open(output_prefix + ".fa", 'w')

with open(genome, 'r') as f:
   for line in f.readlines():
        if line.startswith(">"):
            accession = line[1:].split()[0]
            print(accession)
            if accession in chr_dict:
                f3.write(">" + chr_dict[accession] + "\n")
                to_save = True
            else:
                to_save = False
        else:
            if to_save:
                f3.write(line)


f3.close()

