# gatk make alt genome changed genome name
from sys import argv
import sys

genome = argv[1]
output_prefix = argv[2]
    

f3 = open(output_prefix + ".fa", 'w')

with open(genome, 'r') as f:
   for line in f.readlines():
        if line.startswith(">"):
            name = line[1:].split(" ")[1].split(":")[0]
            f3.write(">" + name + "\n")
        else:
            f3.write(line)


f3.close()

