# parse a gtf file and count how many times an attribute (in col 9) is present, w.o considering feature (col 3)

from sys import argv
import sys

# argv[1] = input
# argv[2] = feature/attr

feature = argv[2]
filter_set = dict()
line_num = 0
with open(argv[1], 'r') as f:
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
                    if name not in filter_set:
                        filter_set[name] = 0
                    filter_set[name] += 1

print(len(filter_set), "distinct", feature, "identified from", argv[2], file=sys.stderr)
print(line_num, "non-header lines found from", argv[2], file=sys.stderr)

for k,v in filter_set.items():
    print(str(k) + '\t' + str(v))



