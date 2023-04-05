# run experiments for altai and other tool
vcf="dm6.intersect.selected.gt.vcf"
genome="dm6_paternal_genome.fa"

################################ preparations: index and alignment ###############
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



