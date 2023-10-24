# polyester 1.22.0 cannot take non-positive expression values of transcripts
# make abundance at lease 1
# need to change both expression profile and tx.fa accordingly

import sys
from sys import argv
fafile = argv[1]
profile = argv[2]
outprefix = argv[3]

outpro = open(outprefix + ".txabd.tsv", 'w')
skip_idx = set()
keep_name = set()
with open(profile, 'r') as f:
    lines = f.readlines()
    for i in range(len(lines)):
        # line has "\n" at the end, not stripped
        line = lines[i]
        if line.startswith("#"):
            outpro.write(line)
        else:
            value = int(line.split('\t')[3])
            assert int(line.split('\t')[2]) != 0  # length cannot be 0
            if value < 1:
                idx = i - 1  # b/c header
                skip_idx.add(idx)
            else:
                outpro.write(line)
                keep_name.add(line.split('\t')[0])
outpro.close()

skip_idx = set() # dont use it

#print(keep_name)

outfa = open(outprefix + ".no0tx.fa", 'w')
idx_counter = -1  # increment before index check, so init -1
tx_name = ""
with open(fafile, 'r') as f:
    lines = f.readlines()
    for i in range(len(lines)):
        # line has "\n" at the end, not stripped
        line = lines[i]
        if line.startswith("#"):
            outfa.write(line)
        elif line.startswith(">"):
            idx_counter += 1
            tx_name = line[1:].strip()
            #print(tx_name)
            if tx_name in keep_name:
                outfa.write(line)
        else:
            # seq lines, idx_counter is idx of current tx
            if tx_name in keep_name:
                outfa.write(line)
outfa.close()
