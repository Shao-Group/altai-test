# generate sample-allele-specific gtf files from expression profile tsv
# Input tsv, a general gtf
# output: Allele-1 gtf (keep transcripts if expression level in allele1 is positive)
#	  Allele-1-specific gtf (keep transcripts if expression level in allele1 is positive AND expression in allele2 is 0)
#	  Allele-2 gtf
#	  Allele-2-specific gtf
#	  sample-merged gtf (keep transcripts if expression level in allele1 and/or allele2 is positive. i.e. removing transcripts only if no expression in both alleles)



# keep lines in file 1 by file2's attribute (given by argv[3])
import os
from sys import argv

# argv[1] = input
# argv[2] = filter gtf
# argv[3] = feature


# abundance tsv example
##tx_name	gene_name	tx_len	tx_exp	txmate_exp	txASE	gene_exp	genemate_exp	geneASE
# gnl|FlyBase|CR40469-RA_pat	Dmel_CR40469	214	4	0	1.0	4	0	1.0
# gnl|FlyBase|CG17636-RA_pat	Dmel_CG17636	1894	4	4	0.5	15	15	0.5
# gnl|FlyBase|CG17636-RB_pat	Dmel_CG17636	2036	4	4	0.5	15	15	0.5
# gnl|FlyBase|CG17636-RC_pat	Dmel_CG17636	2028	7	7	0.5	15	15	0.5
# gnl|FlyBase|CG40494-RD_pat	Dmel_CG40494	5083	15	15	0.5	88	88	0.5
# gnl|FlyBase|CG40494-RE_pat	Dmel_CG40494	5089	15	15	0.5	88	88	0.5


# return (allele1 name if attr non-zero, allele2 name if attr non-zero)
# see usage in `non_zero_transcripts` and `non_zero_genes`
def non_zero_col(tsv, name_col, attr_col):    
    non_zero_merged = []
    with open(tsv, 'r') as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith("#"):
                assert line.split() == "#tx_name	gene_name	tx_len	tx_exp	txmate_exp	txASE	gene_exp	genemate_exp	geneASE".split()
                continue
            elif line == "":
                continue
            else:
                attr = line.split("\t")
                assert(len(attr) == 9)
                if float(attr[attr_col]) > 0:
                    non_zero_merged.append(attr[name_col])
    
    non_zero_allele1 = []
    non_zero_allele2 = []
    for i in non_zero_merged:
        if i.endswith("_pat"): 
            non_zero_allele1.append(i[:-4])
        elif i.endswith("_mat"): 
            non_zero_allele2.append(i[:-4])
        else:
            assert 0
    return non_zero_allele1, non_zero_allele2

                

# return (allele1_trsts, allele2_trsts)
def non_zero_transcripts(tsv):
    return non_zero_col(tsv, 0, 3)

# return (allele1_trsts, allele2_trsts)
def non_zero_genes(tsv):
    return non_zero_col(tsv, 0, 6)

def get_gtf_lines_by_id(gtf, which, filter_set):
    assert(which == "gene_id" or which == "transcript_id")
    out_lines = []
    with open(gtf, 'r') as f:
        for line in f.readlines():
            line = line.strip()
            assert line != ""
            if line.startswith("#"):
                out_lines.append(line)
                continue

            ft = line.split("\t")[2]
            if ft != "gene" and ft != "transcript" and ft != "exon":
                continue

            attr = line.split("\t")[8]
            for i in attr.split(";"):
                if i == '':
                    continue
                x = i.strip().split(" ", 1)
                if len(x) != 2:
                    continue
                feature_type, name = x
                if feature_type != which:
                    continue
                # remove double quotes
                if name.startswith('\"'):
                    name = name[1:]
                if name.endswith('\"'):
                    name = name[:-1]
                if name in filter_set:
                    out_lines.append(line)
                    break
    return out_lines


def write_lines(gtf_lines, outname):
    with open(outname, 'w') as f:
        f.write('\n'.join(gtf_lines))


if __name__ == "__main__":
    assert(len(argv) == 4)
    gtf, tsv, outname = argv[1:]
    if not gtf.endswith(".gtf") or not tsv.endswith(".tsv"):
        print("Usage: python gtf_allele_specific.py gtf_file allele_transcripts_expression_tsv")
    assert(gtf.endswith(".gtf"))
    assert(tsv.endswith(".tsv"))

    as1tx , as2tx = non_zero_transcripts(tsv)
    
    as1tx_lines     = get_gtf_lines_by_id(gtf, "transcript_id", as1tx)
    as2tx_lines     = get_gtf_lines_by_id(gtf, "transcript_id", as2tx)
    as1tx_sp_lines  = get_gtf_lines_by_id(gtf, "transcript_id", set(as1tx).difference(set(as2tx)))
    as2tx_sp_lines  = get_gtf_lines_by_id(gtf, "transcript_id", set(as2tx).difference(set(as1tx)))
    both_tx_lines   = get_gtf_lines_by_id(gtf, "transcript_id", set(as1tx).intersection(set(as2tx)))
    either_tx_lines = get_gtf_lines_by_id(gtf, "transcript_id", set(as1tx).union(set(as2tx)))

    write_lines(as1tx_lines,        outname + ".allele1.gtf")
    write_lines(as2tx_lines,        outname + ".allele2.gtf")
    write_lines(as1tx_sp_lines,     outname + ".allele1spec.gtf")
    write_lines(as2tx_sp_lines,     outname + ".allele2spec.gtf")
    write_lines(both_tx_lines,      outname + ".nonspec.gtf")
    write_lines(either_tx_lines,    outname + ".merged.gtf")

    # as1gene, as2gene = non_zero_genes(tsv)
    # as1gene_lines  = get_gtf_lines_by_id(gtf, "gene_id", as1gene)
    # as2genes_lines = get_gtf_lines_by_id(gtf, "gene_id", as2gene)
