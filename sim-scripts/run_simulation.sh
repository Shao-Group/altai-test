## simulate diploid genome, di-transcriptome, di-tx expression, and RNA-seq reads of di-tx expression

cd sim-data
mkdir tmp

################################# pre-process ####################################################################################
# conda activate simulation
# remove repeats from gtf
sh ../sim-scripts/gtf_rm_repeats.sh  ../ref-data/GCA_000001215.4/genomic.gtf ../ref-data/simpleRepeat_dm6_Aug2014.bed  dm6

# keep transcripts with exonic vcf & select one variation (randomly) for each exon
# make vcf phased, all ref SNP in paternal genome and all alt SNP in maternal genome
sh ../sim-scripts/vcf_exonic.sh dm6.norepeat.gtf  ../ref-data/DGRP2.source_BCM-HGSC.dm6.final.SNPs_only.vcf dm6 dm6.w.var.gtf

# add gt and format 
cat  ../ref-data/dm6_vcf_header > dm6.intersect.selected.gt.vcf
awk -F "\t" '{OFS = "\t"; $9 = "GT"; $10 = "0|1"; print $0}' dm6.intersect.selected.vcf >> dm6.intersect.selected.gt.vcf

mv dm6.intersect.selected.vcf tmp

# get number of transcripts per gene
#awk '{if ($3 == "transcript") print $0}' dm6.w.var.gtf > tmp.var.tx
#python ../sim-scripts/gtf_counter.py tmp.var.tx gene_id | sed 's/\"//g' > tx_w_var.per_gene.count
#cat tx_w_var.per_gene.count | sort -k2 | cut -f 2 | uniq -c | sort -k2n
#rm tmp.var.tx

################### make diploid genome and transcriptome #######################################################################
# make paternal (ref) genome
sh ../sim-scripts/fna_pat.sh ../ref-data/GCA_000001215.4/GCA_000001215.4_Release_6_plus_ISO1_MT_genomic.fna  ../ref-data/GCA_000001215.4/chr_name_fna.txt dm6.intersect.selected.gt.vcf
# make maternal (alt) genome
# conda activate gatk4
sh ../sim-scripts/fna_mat.sh ../ref-data/GCA_000001215.4/GCA_000001215.4_Release_6_plus_ISO1_MT_genomic.fna  ../ref-data/GCA_000001215.4/chr_name_fna.txt dm6.intersect.selected.gt.vcf

# make transcriptome
# conda activate simulation
sh ../sim-scripts/fna_tx.sh 

################### make reads for diploid transcriptome #######################################################################
# make expression for both allele of transcriptomes
samtools faidx dm6_maternal_tx.fa 
cut -f 1-2 dm6_maternal_tx.fa.fai > tx.length
rm dm6_maternal_tx.fa.fai
# make reads
num_tx=$(cat dm6_maternal_tx.fa | grep -c "^>") # actually not used
for j in 1 2 3 4 
do
        python ../sim-scripts/make_abundance.py dm6.w.var.gtf tx.length dm6_di-txm.exp_sim.$j.tsv
	python ../sim-scripts/make_reads_no0.py dm6_diploid_tx.fa dm6_di-txm.exp_sim.$j.tsv "tmp".dm6.polyester.$j
	for num_reads in 3e6 25e6 60e6
	do
		output=simdm6_exp"$j"_reads"$num_reads"
		mkdir $output
		cp dm6_di-txm.exp_sim.$j.tsv $output
		cp "tmp".dm6.polyester.$j".txabd.tsv" "tmp".dm6.polyester.$j".no0tx.fa"  $output
		Rscript ../sim-scripts/make_reads.R  \
			$output/"tmp".dm6.polyester.$j".no0tx.fa" \
			$num_tx \
		       	$num_reads $output/"tmp".dm6.polyester.$j".txabd.tsv" \
		       	$output \
			1> $output/polye.log 2> $output/polye.err
	done
	mv dm6_di-txm.exp_sim.$j.tsv tmp
	mv "tmp".dm6.polyester.$j".txabd.tsv" "tmp".dm6.polyester.$j".no0tx.fa" tmp
done





################################ preparations for assembly: index and alignment ###############
vcf="dm6.intersect.selected.gt.vcf"
genome="dm6_paternal_genome.fa"

# star index, align, sort
mkdir index-star
sh ../sim-scripts/do_index.sh $genome index-star

for i in $(ls | grep sim)
do
	cd $i
	echo "current dir is" $i ":="  $(pwd)
	
	mkdir aligned_star
	for sample_id in sample_01 sample_02
	do
		output_prefix="aligned_star/"$sample_id
		echo "start to align sample" $sample_id
		sh ../../sim-scripts/do_star.sh ../index-star $sample_id"_1.fasta" $sample_id"_2.fasta" ../$vcf $output_prefix
		echo "finished align sample" $sample_id
	done
	
	cd ..
done



