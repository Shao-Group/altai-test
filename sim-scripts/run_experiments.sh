#!/usr/bin/sh
cd sim-results

################ run assembly, get allelic gtf ground truth, eval with gffcompare #############
vcf=../sim-data/dm6.intersect.selected.gt.sorted.vcf
genome=../sim-data/dm6_paternal_genome.fa

for i in $(ls ../sim-data/ | grep sim)
do
	echo current dataset is $i
	for sample_id in sample_01 sample_02
	do
		bam=../sim-data/$i/aligned_star/$sample_id.starW.Aligned.sortedByCoord.out.bam
		left=../sim-data/$i/"$sample_id"_1.fasta
		right=../sim-data/$i/"$sample_id"_2.fasta
	
	
		merge_gtf="../sim-data/dm6.w.var.gtf"            ## should use a specific gtf as simulation may have some tx being 0-abd in both alleles
		pat_gtf=""
		mat_gtf=""
        	library="second"
		prefix=$i.$sample_id
		sh ../sim-scripts/do_assembly.sh $bam $vcf $genome $prefix $library $merge_gtf $pat_gtf $mat_gtf &
	done
done	


