#!/usr/bin/sh

# generate allele specific gtf using assembly + quantification

## init ##
#$bam $vcf $genome $prefix $library $pat_genome $mat_genome $merge_gtf $pat_gtf $mat_gtf
bam=$1
vcf=$2
genome=$3
out_prefix=$4
library_type=$5
pat_genome=$6
mat_genome=$7

#################################### assembly ###########################
scallop2 -i $bam \
	 -o scallop2.$4.gtf \
	 --library_type $library_type \
         --verbose 2


