# input:
# $1 = gtf file
# $2 = vcf

# output:
# $3 =  output name


# vcf change chr name & keep minimal info
echo "##fileformat=VCFv4.2" >> $3.SNP.vcf
cat ../ref-data/DGRP2.source_BCM-HGSC.dm6.final.SNPs_only.vcf | cut -f 1-8 |  grep -v "^#" | \
      awk '{gsub(/^2L/, "chr2L"); gsub(/^2R/, "chr2R"); gsub(/^3L/, "chr3L");
      gsub(/^3R/, "chr3R"); gsub(/^4/, "chr4"); gsub(/^X/, "chrX");
      print;}' | \
      grep '^#\|^chr' >> $3.SNP.vcf


# exonic gtf
awk '{if ($3 == "exon") print $0; }' $1 >  "tmp.exonic.gtf" 

# keep exons w. vcf
bedtools intersect -a "tmp.exonic.gtf" -b $3.SNP.vcf -wa > intersect.exons

# keep 1 vcf per exon
cat "tmp.exonic.gtf" | cut -f 1,4-5 | sort | uniq > "exonic.bed" 
bedtools intersect -a "exonic.bed" -b dm6.SNP.vcf -wa  -wb > intersect.exon_w_vcf 

# filter and random select one variation per exon
python -c \
"
import sys.argv
imoprt random

cur_exon = []
candidate_variations = []
with open(argv[1], 'r') as f:
	for line in f.readlines():
		if line.startswith("#"):
			continue
		else:
			x = line.split('\t')
			exon = x[1:3]
			if exon == cur_exon:
				candidate_variations.append(x[3:])
			else:
				chosen = random.choice(candidate_variations)
				print('\t'.join(chosen))
				cur_exon = exon
				candidate_variations = []

chosen = random.choice(candidate_variations)
print('\t'.join(chosen))
" intersect.exon_w_vcf
