#!/usr/bin/sh

# generate allele specific gtf using assembly + quantification

## init ##
#$bam $vcf $genome $prefix $library $pat_genome $mat_genome $merge_gtf $pat_gtf $mat_gtf

must_assemble=false

bam=$1
left=$2
right=$3
out_prefix=$4
library_type=$5
pat_genome=$6
mat_genome=$7
library_kallisto=$8

#################################### assembly ###########################
if [ "$must_assemble" = true ]
then
	scallop2 -i $bam \
		 -o scallop2.$4.gtf \
		 --library_type $library_type \
         	--verbose 2
else
	echo scallop2 assembly skipped for $1
fi

mkdir assembly_quant

gffread -w assembly_quant/scallop2.$4.allele1.fa -g $pat_genome scallop2.$4.gtf
gffread -w assembly_quant/scallop2.$4.allele2.fa -g $mat_genome scallop2.$4.gtf

kallisto index      -i assembly_quant/scallop2.$4.allele1.index    assembly_quant/scallop2.$4.allele1.fa
kallisto quant -t 8 -i assembly_quant/scallop2.$4.allele1.index -o assembly_quant/scallop2.$4.allele1.quant $library_kallisto $left $right

kallisto index 	    -i assembly_quant/scallop2.$4.allele2.index    assembly_quant/scallop2.$4.allele2.fa
kallisto quant -t 8 -i assembly_quant/scallop2.$4.allele2.index -o assembly_quant/scallop2.$4.allele2.quant $library_kallisto $left $right


# grab by non zero

