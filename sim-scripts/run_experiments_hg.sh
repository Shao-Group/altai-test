#!/usr/bin/sh

must_make_as_gtf=false
must_run_altai=true
must_run_asmb_quant=false
must_run_asmb_denovo=false

cd sim-results

################ run assembly, get allelic gtf ground truth, eval with gffcompare #############
vcf="../sim-data/hg38.hetero.gt.sorted.vcf"
genome="../sim-data/hg38_paternal_genome.fa"
pat_genome="../sim-data/hg38_paternal_genome.fa"
mat_genome="../sim-data/hg38_maternal_genome.fa"

for i in $(ls ../sim-data/ | grep simhg)
do
	echo current dataset is $i
	
	################ get allelic gtf ground truth #############
	general_gtf="../sim-data/hg38.chr1-22X.gtf"
	tsv="../sim-data/$i/hg38_di-txm.exp_sim.*.tsv"
	out_gtf="../sim-data/$i/sample_spec"
	pat_gtf=$out_gtf".allele1.gtf"
	mat_gtf=$out_gtf".allele2.gtf"
	pat_spec_gtf=$out_gtf".allele1spec.gtf"
	mat_spec_gtf=$out_gtf".allele2spec.gtf"
	merge_gtf=$out_gtf".merged.gtf"
	nonspec_gtf=$out_gtf".nonspec.gtf"
	if [ "$must_make_as_gtf" = true ] ||  [ ! -f $pat_gtf ] || [ ! -f $mat_gtf ] || [ ! -f $pat_spec_gtf ] || [ ! -f $mat_spec_gtf ] || [ ! -f $merge_gtf ] || [ ! -f $nonspec_gtf ] 
	then
		echo generate sample specific gtf files for $i
		python ../sim-scripts/gtf_allele_specific.py  $general_gtf $tsv $out_gtf
	else
		echo sample specific gtf files for $i already generated
	fi

	################ run assemblies ##########################
	for sample_id in sample_01 
	do
		bam=../sim-data/$i/aligned_star/$sample_id.starW.Aligned.sortedByCoord.out.bam
		left=../sim-data/$i/"$sample_id"_1.fasta
		right=../sim-data/$i/"$sample_id"_2.fasta	
		library="second"
		library_spades="rf"
		library_kallisto="--fr-stranded" # note kallisto lib type is different from altai/scallop
		prefix=$i.$sample_id
		
		if [ "$must_run_altai" = true ]
		then
			sh ../sim-scripts/do_altai.sh $bam $vcf $genome $prefix $library 
		fi
		if [ "$must_run_asmb_quant" = true ]
		then
			sh ../sim-scripts/do_assembly_quant.sh $bam $left $right $prefix $library $pat_genome $mat_genome $library_kallisto
		fi
		if [ "$must_run_asmb_denovo" = true ]
		then	
			sh ../sim-scripts/do_assembly_denovo.sh $left $right $prefix $library_spades		
		fi
		
		# Evaluation 
		sh ../sim-scripts/do_gffcompare.sh $pat_gtf $mat_gtf $pat_spec_gtf $mat_spec_gtf $nonspec_gtf $merge_gtf $prefix "." "."

	done
done	


