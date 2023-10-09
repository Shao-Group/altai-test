#!/usr/bin/sh

must_make_as_gtf=false
must_run_altai=true
must_run_asmb_quant=false
must_run_asmb_denovo=false

cd sim-results

################ run assembly, get allelic gtf ground truth, eval with gffcompare #############
vcf=../sim-data/dm6.intersect.selected.gt.sorted.vcf
genome=../sim-data/dm6_paternal_genome.fa

for i in $(ls ../sim-data/ | grep sim)
do
	echo current dataset is $i
	echo generate sample specific gtf files
	
	################ get allelic gtf ground truth #############
	general_gtf="../sim-data/dm6.w.var.gtf"
	tsv="../sim-data/$i/dm6_di-txm.exp_sim.*.tsv"
	out_gtf="../sim-data/$i/sample_spec"
	pat_gtf=$out_gtf".allele1.gtf"
	mat_gtf=$out_gtf".allele2.gtf"
	pat_spec_gtf=$out_gtf".allele1spec.gtf"
	mat_spec_gtf=$out_gtf".allele2spec.gtf"
	merge_gtf=$out_gtf".merged.gtf"
	nonspec_gtf=$out_gtf".nonspec.gtf"
	if [ "$must_make_as_gtf" == true ] ||  [ ! -f $pat_gtf ] || [ ! -f $mat_gtf ] || [ ! -f $pat_spec_gtf ] || [ ! -f $mat_spec_gtf ] || [ ! -f $merge_gtf ] || [ ! -f $nonspec_gtf ] 
	then
		python ../sim-scripts/gtf_allele_specific.py  $general_gtf $tsv $out_gtf
	fi

	################ run assemblies ##########################
	for sample_id in sample_01 sample_02
	do
		bam=../sim-data/$i/aligned_star/$sample_id.starW.Aligned.sortedByCoord.out.bam
		left=../sim-data/$i/"$sample_id"_1.fasta
		right=../sim-data/$i/"$sample_id"_2.fasta	
		library="second"
		library_spades="rf"
		prefix=$i.$sample_id
		
		if [ "$must_run_altai" = true ]
		then
			sh ../sim-scripts/do_assembly.sh $bam $vcf $genome $prefix $library $merge_gtf $pat_gtf $mat_gtf 
		fi
		if [ "$must_run_asmb_quant" = true ]
		then
			sh ../sim-scripts/do_assembly_quant.sh $bam $vcf $genome $prefix $library $merge_gtf $pat_gtf $mat_gtf 
		fi
		if [ "$must_run_asmb_denovo" = true ]
		then	
			sh ../sim-scripts/do_assembly_denovo.sh $left $right $prefix $library_spades		
		fi
	done
done	


