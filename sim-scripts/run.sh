cd sim_data
mkdir tmp

# remove repeats from gtf
sh ../sim-scripts/gtf_rm_repeats.sh  ../ref-data/GCA_000001215.4/genomic.gtf ../ref-data/simpleRepeat_dm6_Aug2014.bed  dm6

# keep transcripts with exonic vcf & select one variation (randomly) for each exon
# make vcf phased, all ref SNP in paternal genome and all alt SNP in maternal genome
sh ../sim-scripts/vcf_exonic.sh dm6.norepeat.gtf  ../ref-data/DGRP2.source_BCM-HGSC.dm6.final.SNPs_only.vcf dm6 dm6.w.var.gtf
echo "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	INTEGRATION"  > dm6.intersect.selected.gt.vcf 
awk -F "\t" '{OFS = "\t"; $9 = "GT"; $10 = "0|1"; print $0}' dm6.intersect.selected.vcf >> dm6.intersect.selected.gt.vcf
mv dm6.intersect.selected.vcf tmp

# get number of transcripts per gene
#awk '{if ($3 == "transcript") print $0}' dm6.w.var.gtf > tmp.var.tx
#python ../sim-scripts/gtf_counter.py tmp.var.tx gene_id | sed 's/\"//g' > tx_w_var.per_gene.count
#cat tx_w_var.per_gene.count | sort -k2 | cut -f 2 | uniq -c | sort -k2n
#rm tmp.var.tx

# make dipoid genome and transcriptome


