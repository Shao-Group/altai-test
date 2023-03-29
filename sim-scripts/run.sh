cd sim_data

# remove repeats from gtf
sh ../sim-scripts/gtf_rm_repeats.sh  ../ref-data/GCA_000001215.4/genomic.gtf ../ref-data/simpleRepeat_dm6_Aug2014.bed  dm6.gene.norepeat.gtf

# vcf change chr name & keep minimal info
cat ../ref-data/DGRP2.source_BCM-HGSC.dm6.final.SNPs_only.vcf | cut -f 1-8 |  grep -v "^#" | \
      awk '{gsub(/^2L/, "chr2L"); gsub(/^2R/, "chr2R"); gsub(/^3L/, "chr3L");
      gsub(/^3R/, "chr3R"); gsub(/^4/, "chr4"); gsub(/^X/, "chrX");
      print;}' | \
      grep '^#\|^chr' > dm6.SNP.vcf

 
python ../sim-scripts/gtf_filter_by.py dm6.gtf dm6.gene.norepeat.gtf gene_id  > dm6.norepeat.gtf
