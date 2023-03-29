cd sim_data

# remove repeats from gtf
sh ../sim-scripts/gtf_rm_repeats.sh  ../ref-data/GCA_000001215.4/genomic.gtf ../ref-data/simpleRepeat_dm6_Aug2014.bed  dm6

# keep transcripts with exonic vcf & select one variation (randomly) for each exon
sh ../sim-scripts/vcf_exonic.sh dm6.norepeat.gtf  ../ref-data/DGRP2.source_BCM-HGSC.dm6.final.SNPs_only.vcf dm6 dm6.w.var.gtf

# get number of transcripts per gene
#awk '{if ($3 == "transcript") print $0}' dm6.w.var.gtf > tmp.var.tx
#python ../sim-scripts/gtf_counter.py tmp.var.tx gene_id | sed 's/\"//g' > tx_w_var.per_gene.count
#cat tx_w_var.per_gene.count | sort -k2 | cut -f 2 | uniq -c | sort -k2n
#rm tmp.var.tx


