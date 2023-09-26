#!/usr/bin/sh

## init ##

bam=$1
vcf=$2
genome=$3
out_prefix=$4
library_type=$5
merge_gtf=$6
pat_gtf=$7
mat_gtf=$8


#################################### assembly ###########################

altai -i $bam \
      -j $vcf \
      -o altai.$4 \
      -f altai.$4.nonfull \
      --library_type $library_type \
      --verbose 0 
      #--verbose 10 --DEBUG --print_bundle_detail --print_phaser_detail --print_scallop_detail # debug parameters


scallop2 -i $bam \
	 -o scallop2.$4.gtf \
	 --library_type $library_type \
         --verbose 0  

# assign scallop2 to 2 based on quant kallisto
# xxxxxx

####################################### gffcompare eval ##################

echo gtf $merge_gtf

gffcompare -r $merge_gtf -o compare.$4.merged.altai   altai.$4.merged.gtf
#gffcompare -r $pat_gtf   -o compare.$4.allele1.altai  altai.$4.allele1.gtf
#gffcompare -r $mat_gtf   -o compare.$4.allele2.altai  altai.$4.allele2.gtf

gffcompare -r $merge_gtf -o compare.$4.merged.scallop2   scallop2.$4.gtf
#gffcompare -r $pat_gtf   -o compare.$4.allele1.scallop2  scallop2.$4.allele1.gtf
#gffcompare -r $mat_gtf   -o compare.$4.allele2.scallop2  scallop2.$4.allele2.gtf


