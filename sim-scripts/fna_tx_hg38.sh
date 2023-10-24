# make transcripts of both alleles
cat ../ref-data/Homo_sapiens.GRCh38.97.gtf | awk '{if ($1 == 1 || $1 == 2 || $1 == 3 || $1 == 4 || $1 == 5  || $1 == 6 || $1 == 7 || $1 == 8 || $1 == 9  || $1 == 10 || $1 == 11 || $1 == 12 || $1 == 13 || $1 == 14 || $1 == 15 || $1 == 16 || $1 == 17 || $1 == 18 || $1 == 19 || $1 == 20 || $1 == 21 || $1 == 22 || $1 == X) print $0;}' | awk '{if($3 == "exon" || $3 == "transcript") {print $0;} }' > hg38.chr1-22X.gtf

gffread -w hg38_paternal_tx.fa -g hg38_paternal_genome.fa hg38.chr1-22X.gtf
gffread -w hg38_maternal_tx.fa -g hg38_maternal_genome.fa hg38.chr1-22X.gtf

# merge fasta file
cat hg38_paternal_tx.fa | awk '{if ($1 ~ /^>/) print ($0"_pat");  else print $0; }' > hg.pat.tx
cat hg38_maternal_tx.fa | awk '{if ($1 ~ /^>/) print ($0"_mat");  else print $0; }' > hg.mat.tx
cat hg.pat.tx hg.mat.tx > hg_diploid_tx.fa
rm hg.pat.tx hg.mat.tx
