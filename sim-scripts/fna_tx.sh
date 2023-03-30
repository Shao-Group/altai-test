# make transcripts of both alleles
gffread -w dm6_paternal_tx.fa -g dm6_paternal_genome.fa dm6.w.var.gtf
gffread -w dm6_maternal_tx.fa -g dm6_maternal_genome.fa dm6.w.var.gtf

# merge fasta file
cat dm6_paternal_tx.fa | awk '{if ($1 ~ /^>/) print ($0"_pat");  else print $0; }' > pat.tx
cat dm6_maternal_tx.fa | awk '{if ($1 ~ /^>/) print ($0"_mat");  else print $0; }' > mat.tx
cat pat.tx mat.tx > dm6_diploid_tx.fa
rm pat.tx mat.tx
