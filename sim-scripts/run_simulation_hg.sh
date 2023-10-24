## simulate diploid genome, di-transcriptome, di-tx expression, and RNA-seq reads of di-tx expression

cd sim-data
mkdir tmp

################################# pre-process ####################################################################################
# conda activate simulation
# add gt and format 
cat ../ref-data/HG001_GRCh38_1_22_v4.2.1_benchmark_hifiasm_v11_phasetransfer.subonly.vcf | grep "^#" > hg_vcf_header
cat  hg_vcf_header > hg38.hetero.gt.vcf
# make allele1 all ref, allele2 all alt 
cat ../ref-data/HG001_GRCh38_1_22_v4.2.1_benchmark_hifiasm_v11_phasetransfer.subonly.vcf | awk '{if (substr($10, 2, 1) == "|" && (substr($10, 1, 1) != substr($10, 3, 1) ) ) {$9 = "GT"; $10 = "0|1"; print $0;}}' >> hg38.hetero.gt.vcf


################### make diploid genome and transcriptome #######################################################################
# make paternal (ref) genome
cp ../ref-data/Homo_sapiens.GRCh38.dna.primary_assembly.fa  hg38_paternal_genome.fa
samtools faidx hg38_paternal_genome.fa
samtools dict hg38_paternal_genome.fa > hg38_paternal_genome.dict
# make maternal (alt) genome
gatk SortVcf -I hg38.hetero.gt.vcf -O hg38.hetero.gt.sorted.vcf
mv hg38.hetero.gt.vcf tmp
gatk IndexFeatureFile -I hg38.hetero.gt.sorted.vcf
gatk FastaAlternateReferenceMaker \
   -R hg38_paternal_genome.fa \
   -O hg38_maternal_genome.fa \
   -V hg38.hetero.gt.sorted.vcf
rm hg38_maternal_genome.dict
rm hg38_maternal_genome.fa.fai
python ../sim-scripts/fna_gatk_chrname.py hg38_maternal_genome.fa hg38_maternal_genome.fa1
mv hg38_maternal_genome.fa1.fa hg38_maternal_genome.fa
samtools faidx hg38_maternal_genome.fa
samtools dict hg38_maternal_genome.fa > hg38_maternal_genome.dict


# make transcriptome
# conda activate simulation
sh ../sim-scripts/fna_tx_hg38.sh

################### make reads for diploid transcriptome #######################################################################
# make expression for both allele of transcriptomes
samtools faidx hg38_maternal_tx.fa 
cut -f 1-2 hg38_maternal_tx.fa.fai > tx.length
rm hg38_maternal_tx.fa.fai
# make reads
for j in 1 2 3 4 
do
        python ../sim-scripts/make_abundance0.py hg_diploid_tx.fa  tx.length hg38_di-txm.exp_sim.$j.tsv
	python ../sim-scripts/make_reads_no0.py hg_diploid_tx.fa hg38_di-txm.exp_sim.$j.tsv "tmp".hg38.polyester.$j
	for num_reads in 30e6  
	do
		output=simhg38_exp"$j"_reads"$num_reads"
		mkdir $output
		cp hg38_di-txm.exp_sim.$j.tsv $output
		cp "tmp".hg38.polyester.$j".txabd.tsv" "tmp".hg38.polyester.$j".no0tx.fa"  $output
		Rscript ../sim-scripts/make_reads.R  \
			$output/"tmp".hg38.polyester.$j".no0tx.fa" \
			$num_tx \
		       	$num_reads $output/"tmp".hg38.polyester.$j".txabd.tsv" \
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

for i in $(ls | grep "^simhg")
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



