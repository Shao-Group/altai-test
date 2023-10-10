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
if [ "$must_assemble" = true ] || [ ! -f scallop2.$4.gtf ]
then
	scallop2 -i $bam \
		 -o scallop2.$4.gtf \
		 --library_type $library_type \
         	 --verbose 2 \
		 1> scallop2.$4.log 2> scallop2.$4.err
else
	echo scallop2 assembly skipped for $1
fi


if [ ! -d assembly_quant ]
then
	mkdir assembly_quant
fi

# make merged-alleles transcripts fasta
gffread -w assembly_quant/scallop2.$4.pat.fa -g $pat_genome scallop2.$4.gtf
gffread -w assembly_quant/scallop2.$4.mat.fa -g $mat_genome scallop2.$4.gtf
sed -i 's/^>/>pat_/' assembly_quant/scallop2.$4.pat.fa
sed -i 's/^>/>mat_/' assembly_quant/scallop2.$4.mat.fa
cat assembly_quant/scallop2.$4.pat.fa assembly_quant/scallop2.$4.mat.fa > assembly_quant/scallop2.$4.patmat.fa


# kallisto quant on merged sc2 outptus
kallisto index      -i assembly_quant/scallop2.$4.index    assembly_quant/scallop2.$4.patmat.fa \
	1> assembly_quant/kallisto_index.$4.log 2> assembly_quant/kallisto_index.$4.err
kallisto quant -t 8 -i assembly_quant/scallop2.$4.index -o assembly_quant/scallop2.$4.quant $library_kallisto $left $right \
	1> assembly_quant/kallisto_quant.$4.log 2> assembly_quant/kallisto_quant.$4.err

# grab by non zero: skip first line, estimate count > 0, 
as1_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.ale1.id"
as2_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.ale2.id"
as1_spec_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.ale1spec.id"
as2_spec_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.ale2spec.id"
nonspec_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.nonspec.id"
merged_id="assembly_quant/scallop2.$4.quant/expressed.transcripts.merged.id"

tail -n +2 assembly_quant/scallop2.$4.quant/abundance.tsv | awk '{if ($4 > 0) {print $1;}}' > assembly_quant/scallop2.$4.quant/expressed.transcripts.id
cat assembly_quant/scallop2.$4.quant/expressed.transcripts.id | grep "^pat_" | sed 's/^pat_//' | sort > $as1_id
cat assembly_quant/scallop2.$4.quant/expressed.transcripts.id | grep "^mat_" | sed 's/^mat_//' | sort > $as2_id
comm -12 $as1_id $as2_id > $merged_id
comm -13 $as1_id $as2_id > $as2_spec_id
comm -23 $as1_id $as2_id > $as1_spec_id
cat $as1_id $as2_id | sort | uniq > $nonspec_id

gffread -T --ids $as1_id      -o scallop2.$4.allele1.gtf     scallop2.$4.gtf >> gffread.log
gffread -T --ids $as2_id      -o scallop2.$4.allele2.gtf     scallop2.$4.gtf >> gffread.log
gffread -T --ids $as1_spec_id -o scallop2.$4.allele1spec.gtf scallop2.$4.gtf >> gffread.log
gffread -T --ids $as2_spec_id -o scallop2.$4.allele2spec.gtf scallop2.$4.gtf >> gffread.log
gffread -T --ids $nonspec_id  -o scallop2.$4.nonspec.gtf     scallop2.$4.gtf >> gffread.log
gffread -T --ids $merged_id   -o scallop2.$4.merged.gtf      scallop2.$4.gtf >> gffread.log



