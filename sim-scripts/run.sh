cd sim_data
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





