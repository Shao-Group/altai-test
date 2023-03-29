# replace chr names, keep only autsomes and XY
# $1 original genome
# $2 chr name select/replace list
# $3 vcf

python ../sim-scripts/fna_select_chr_by_name.py $1 $2 dm6_paternal_genome

gatk SortVcf -I $3 -O $3.sorted.vcf

gatk IndexFeatureFile -F $3.sorted.vcf

gatk FastaAlternateReferenceMaker \
   -R dm6_paternal_genome.fa \
   -O dm6_maternal_genome.fa \
   -V $3


