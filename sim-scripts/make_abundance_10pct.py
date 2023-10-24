import sys
from sys import argv
import random
import json
import os

gtf_file = argv[1]
length_file = argv[2]
if len(argv) >= 4:
    output = argv[3]
else:
    output = "sim.diploid_tx.abundance.tsv"
if argv[-1] == "to_print":
    to_print = True
else:
    to_print = False

# gtf_file = "../sim-data/dm6.w.var.gtf"
# length_file = "../sim-data/tx.length"
# output = "../sim-data/sim.diploid_tx.abundance.tsv"
# to_print = True

seed1 = hash(output)
random.seed(seed1)

# read gene to tx, and tx to gene
tx_to_gene = dict()
gene_to_tx = dict()
with open (gtf_file, 'r') as f:
    for line in f.readlines():
        if line.startswith("#"):
            continue
        else:
            gene = ""
            tx = ""
            attrs = line.strip().split('\t')[8]
            for i in attrs.split(";"):
                if i == '':
                    continue
                x = i.strip().split(" ", 1)
                if len(x) != 2:
                    continue
                feature_type, name = x
                if feature_type == "gene_id":
                    assert name[0] == "\"" and name[-1] == "\""
                    gene = name[1:-1]
                elif feature_type == "transcript_id":
                    assert name[0] == "\"" and name[-1] == "\""
                    tx = name[1:-1]
            if gene not in gene_to_tx:
                gene_to_tx[gene] = {tx}
            else:
                gene_to_tx[gene].add(tx)
            if tx in tx_to_gene:
                if tx_to_gene[tx] != gene:
                    print(tx, gene, tx_to_gene[tx], gene_to_tx[gene])
                assert tx_to_gene[tx] == gene
            else:
                tx_to_gene[tx] = gene


# pick 10% genes
gene_pick = list(gene_to_tx.keys())
random.shuffle(gene_pick)
gene_pick = gene_pick[: int(0.1 *len(gene_pick))]
gene_to_tx2 = dict()
tx_to_gene2 = dict()
for k in gene_pick:
    gene_to_tx2[k] = gene_to_tx[k]
    for t in gene_to_tx[k]:
        tx_to_gene2[t] = k
gene_to_tx = gene_to_tx2
tx_to_gene = tx_to_gene2


if to_print:
    # gene_to_tx_list = {gene:list(txs) for gene, txs in gene_to_tx.items()}
    # print(json.dumps(gene_to_tx_list, indent=1))
    # print(json.dumps(tx_to_gene, indent=1))
    pass


# read tx length
tx_to_len = dict()
tx_list = []
tx_idx = dict()
with open (length_file, 'r') as f2:
    idx = 0
    for line in f2.readlines():
        line = line.strip()
        tx, length = line.split()
        if tx not in tx_to_gene:
            continue
        assert tx not in tx_to_len
        tx_to_len[tx] = int(length)
        tx_list.append(tx)
        tx_idx[tx] = idx
        idx += 1
assert len(tx_to_len) == len(tx_to_gene)
assert len(tx_to_len) == len(tx_list)

if to_print:
    # print(len(tx_list), tx_list)
    # print(json.dumps(tx_idx, indent=1), len(tx_idx))
    # print(json.dumps(tx_to_len, indent=1), len(tx_to_len))
    pass


# randomly choose half genes to have ASE/ASAS
num_tx = len(tx_list)
num_gene = len(gene_to_tx)
genes = list(gene_to_tx.keys())
multi_isoform_genes = []
for gene, txs in gene_to_tx.items():
    if len(txs) >= 2:
        multi_isoform_genes.append(gene)

random.shuffle(genes)
as_gene = genes[:int(num_gene/2)]
# at least > 1000 multi-isoform genes
while len(set(as_gene).intersection(set(multi_isoform_genes))) < 1000:
    print("re-choose ase_genes to have > 1000 multi-isoform genes", file=sys.stderr)
    random.shuffle(genes)
    as_gene = genes[:int(num_gene/2)]

as_single_gene = list(set(as_gene).difference(set(multi_isoform_genes)))
as_multi_gene = list(set.intersection(set(as_gene), set(multi_isoform_genes)))
assert len(as_single_gene) + len(as_multi_gene) == int(num_gene/2)
assert len(set(as_single_gene).intersection(set(as_multi_gene))) == 0
if to_print:
    # print(as_single_gene)
    # print(as_multi_gene)
    pass

# For single-exon genes w. ASE:
random.shuffle(as_single_gene)
# For multiple-exon genes w. ASE, half w. gene-level ASE, half w/o
random.shuffle(as_multi_gene)
as_multi_gene_ase_2level = set(as_multi_gene[:int(len(as_multi_gene)/2)])
as_multi_gene_ase_txlevel = set(as_multi_gene[int(len(as_multi_gene)/2):])
assert len(as_multi_gene_ase_2level) + len(as_multi_gene_ase_txlevel) == len(as_multi_gene)
assert len(as_multi_gene_ase_2level.intersection(as_multi_gene_ase_txlevel)) == 0
if to_print:
    print(len(as_gene), "genes have ASE", file=sys.stderr)
    print(len(as_single_gene), "single-isoform genes have ASE", file=sys.stderr)
    print(len(as_multi_gene_ase_2level), "multi-isoform genes have ASE in both isoform- and gene- level", file=sys.stderr)
    print(len(as_multi_gene_ase_txlevel), "multi-isoform genes have ASE in only isoform- but not gene- level", file=sys.stderr)

# ASE of +/- 20%/50%/100%
as_ratios = [0.8, 0.5, 0]
gene_ratio = dict()
gene_abd = dict()
tx_abd = dict()

# assign abundance
for gene, txs in gene_to_tx.items():
    txs = list(txs)
    r = random.choice(as_ratios)
    gene_ratio[gene] = r
    if gene not in as_gene:
        a_sum = 0
        for tx in txs:
            a = random.choice(range(0, 20))
            tx_abd[tx] = (a, a)
            a_sum += a
        gene_abd[gene] = (a_sum, a_sum)
    elif gene in as_single_gene:
        a_sum = random.choice(range(0, 20))
        b_sum = round(a_sum * r)
        # randomize a b _sum
        x = [a_sum, b_sum]
        random.shuffle(x)
        a_sum, b_sum = x
        assert len(txs) == 1
        tx_abd[txs[0]] = (a_sum, b_sum)
        gene_abd[gene] = (a_sum, b_sum)
    elif gene in as_multi_gene_ase_2level:
        a_sum = random.choice(range(0, 20)) * len(txs)
        b_sum = round(a_sum * r)
        # randomize a b _sum
        x = [a_sum, b_sum]
        random.shuffle(x)
        a_sum, b_sum = x
        # isoform abd assign randomly but sum fixed to a_sum and b_sum
        rel_level1 = random.choices(range(0, 20), k=len(txs))
        rel_level2 = random.choices(range(0, 20), k=len(txs))
        if sum(rel_level1) == 0:
            rel_level1 = random.choices(range(1, 20), k=len(txs))
        if sum(rel_level2) == 0:
            rel_level2 = random.choices(range(1, 20), k=len(txs))
        a1 = 0
        b1 = 0
        for i in range(len(txs) - 1):
            a = int(a_sum * (rel_level1[i]/ sum(rel_level1)))
            b = int(b_sum * (rel_level2[i]/ sum(rel_level2)))
            a1 += a
            b1 += b
            assert a >= 0 and b >= 0
            tx_abd[txs[i]] = (a, b)
        a = a_sum - a1
        b = b_sum - b1
        assert a >= 0 and b >= 0
        tx_abd[txs[-1]] = (a, b)
        gene_abd[gene] = (a_sum, b_sum)
    elif as_multi_gene_ase_txlevel:
        a_abs = []
        a_sum = random.choice(range(0, 20)) * len(txs)
        # isoform abd assign randomly but sum fixed to a_sum
        rel_level1 = random.choices(range(0, 20), k=len(txs))
        if sum(rel_level1) == 0:
            rel_level1 = random.choices(range(1, 20), k=len(txs))
        a1 = 0
        for i in range(len(txs) - 1):
            a = int(a_sum * (rel_level1[i] / sum(rel_level1)))
            a1 += a
            assert a >= 0
            a_abs.append(a)
        a = a_sum - a1
        assert a >= 0
        a_abs.append(a)
        a_abs = sorted(a_abs)
        # first in b is decreased by r
        b_abs = a_abs.copy()
        b_abs[-1] = int(a_abs[-1] * r)
        excess = a_abs[-1] - b_abs[-1]
        rel_level2 = random.choices(range(0, 20), k=len(txs)-1)
        if sum(rel_level2) == 0:
            rel_level2 = random.choices(range(1, 20), k=len(txs))
        b1 = 0
        for i in range(len(txs) - 2):
            b_exx = int(excess * (rel_level2[i] / sum(rel_level2)))
            b1 += b_exx
            assert b_exx >= 0
            b_abs[i] = b_abs[i] + b_exx
        b_exx = excess - b1
        b_abs[-2] = b_abs[-2] + b_exx
        assert b_exx >= 0
        assert sum(a_abs) == sum(a_abs)
        # randomize tx, unsort
        x = list(zip(a_abs, b_abs))
        random.shuffle(x)
        selected = random.choice([0, 1])  # which is a, which is b
        for i in range(len(txs)):
            tx_abd[txs[i]] = (x[i][selected], x[i][1-selected])
            # print("tx", selected, (x[i][selected], x[i][1-selected]))
        gene_abd[gene] = (a_sum, a_sum)

# write output
with open(output, 'w') as f:
    outheader = ["#tx_name", "gene_name", "tx_len", "tx_exp", "txmate_exp", "txASE", "gene_exp", "genemate_exp", "geneASE"]
    f.write('\t'.join(outheader) + '\n')
    # write pat allele
    for tx in tx_list:
        gene = tx_to_gene[tx]
        pat_tx, mat_tx = tx_abd[tx]
        pat_gen, mat_gen = gene_abd[tx_to_gene[tx]]
        t_ratio = round(pat_tx/(pat_tx + mat_tx), 2) if pat_tx + mat_tx != 0 else "silent"
        g_ratio = round(pat_gen/(mat_gen + pat_gen), 2) if mat_gen + pat_gen != 0 else "silent"
        l = [tx+"_pat", gene, tx_to_len[tx], pat_tx, mat_tx, t_ratio, pat_gen, mat_gen, g_ratio]
        lstr = [str(x) for x in l]
        assert len(lstr) == len(outheader)
        f.write('\t'.join(lstr) + '\n')
    # write mat allele
    for tx in tx_list:
        gene = tx_to_gene[tx]
        pat_tx, mat_tx = tx_abd[tx]
        pat_gen, mat_gen = gene_abd[tx_to_gene[tx]]
        t_ratio = round(mat_tx / (pat_tx + mat_tx), 2) if pat_tx + mat_tx != 0 else "silent"
        g_ratio = round(mat_gen / (mat_gen + pat_gen), 2) if mat_gen + pat_gen != 0 else "silent"
        l = [tx + "_mat", gene, tx_to_len[tx], mat_tx, pat_tx, t_ratio, mat_gen, pat_gen, g_ratio]
        lstr = [str(x) for x in l]
        assert len(lstr) == len(outheader)
        f.write('\t'.join(lstr) + '\n')

print("make abundance completed!\nCommand:", argv, file=sys.stderr)

