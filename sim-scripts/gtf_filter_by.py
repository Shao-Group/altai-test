from sys import argv

# argv[1] = input
# argv[2] = filter gtf
# argv[3] = feature

feature = argv[3]
filter_set = set()
with open(argv[2], 'r') as f:
    for line in f.readlines():
        line = line.strip()
        if line.startswith("#") or line == "":
            continue
        else:
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


with open(argv[1], 'r') as f:
    for line in f.readlines():
        line = line.strip()
        if line.startswith("#"):
            print(line)
        else:
            assert line != ""
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

