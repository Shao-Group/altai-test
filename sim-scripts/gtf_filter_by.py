# keep lines in file 1 by file2's attribute (given by argv[3])
from sys import argv
import sys

# argv[1] = input
# argv[2] = filter gtf
# argv[3] = feature

feature = argv[3]
filter_set = set()
line_num = 0
with open(argv[2], 'r') as f:
    for line in f.readlines():
        line = line.strip()
        if line.startswith("#") or line == "":
            continue
        else:
            line_num += 1
            attr = line.split("\t")[8]
            for i in attr.split(";"):
                if i == '':
                    continue
                x = i.strip().split(" ", 1)

                #print(line, i, x)
                if len(x) != 2:
                    continue
                feature_type, name = x
                if feature_type == feature:
                    filter_set.add(name)

print(len(filter_set), "distinct", feature, "identified from", argv[2], file=sys.stderr)
print(line_num, "non-header lines found from", argv[2], file=sys.stderr)

with open(argv[1], 'r') as f:
    for line in f.readlines():
        line = line.strip()
        if line.startswith("#"):
            print(line)
        else:
            assert line != ""
            ft = line.split("\t")[2]
            if ft != "gene" and ft != "transcript" and ft != "exon":
                continue
            attr = line.split("\t")[8]
            for i in attr.split(";"):
                if i == '':
                    continue
                x = i.strip().split(" ", 1)
                #print(line, i, x)
                if len(x) != 2:
                    continue
                feature_type, name = x
                if feature_type == feature:
                    if name in filter_set:
                        print(line)
                    break

