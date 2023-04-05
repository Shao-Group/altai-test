# generate index 
# $1 fasta file
# $2 output dir

STAR \
--runThreadN 10 \
--runMode genomeGenerate \
--genomeDir $2 \
--genomeFastaFiles $1


