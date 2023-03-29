# replace chr names, keep only autsomes and XY
# $1 original genome
# $2 chr name select/replace list
# $3 vcf

# change chr name, select chr, index
# conda activate ~/tools/conda_envs/simulation

python ../sim-scripts/fna_select_chr_by_name.py $1 $2 dm6_paternal_genome
samtools faidx dm6_paternal_genome.fa
samtools dict dm6_paternal_genome.fa > dm6_paternal_genome.dict

