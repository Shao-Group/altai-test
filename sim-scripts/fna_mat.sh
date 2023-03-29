# $1 original genome
# $2 chr name select/replace list
# $3 vcf

# make alt genome (maternal)
gatk SortVcf -I $3 -O $3.sorted.vcf
mv $3.sorted.vcf $3
mv $3.sorted.vcf.idx $3.idx

gatk IndexFeatureFile -I $3

gatk FastaAlternateReferenceMaker \
   -R dm6_paternal_genome.fa \
   -O dm6_maternal_genome.fa \
   -V $3

rm dm6_maternal_genome.dict
rm dm6_maternal_genome.fa.fai

# rename chr, reindex
python ../sim-scripts/fna_select_chr_by_name.py dm6_maternal_genome.fa mat_chr_name.txt dm6_maternal_genome1
mv dm6_maternal_genome1.fa dm6_maternal_genome.fa

samtools faidx dm6_maternal_genome.fa
samtools dict dm6_maternal_genome.fa > dm6_maternal_genome.dict
