# alignment of reads to genome
star_index_dir=$1
file1=$2
file2=$3
vcf=$4
out_prefix=$5

# tar does not consider strandness when mapping
# https://github.com/alexdobin/STAR/issues/818

# STAR with vcf/wasp attributes
# vA: allele in read, vG: var genomic pos, vW: WASP filter
STAR --runThreadN 8 \
 --outSAMstrandField intronMotif \
 --outSAMtype BAM Unsorted \
 --chimSegmentMin 20 \
 --genomeDir $1 \
 --twopassMode Basic \
 --varVCFfile $4 \
 --outFileNamePrefix $5."starW." \
 --waspOutputMode SAMtag \
 --outSAMattributes NH HI AS nM NM MD jM jI XS MC ch vA vG vW \
 --readFilesIn $2 $3 

samtools sort -@ 32 $5."starW.Aligned.out.bam" > $5."starW.Aligned.sortedByCoord.out.bam"
rm $5."starW.Aligned.out.bam"

# STAR without vcf/wasp attributes
STAR --runThreadN 8 \
 --outSAMstrandField intronMotif \
 --outSAMtype BAM Unsorted \
 --chimSegmentMin 20 \
 --genomeDir $1 \
 --twopassMode Basic \
 --outFileNamePrefix $5."starO." \
 --readFilesIn $2 $3

samtools sort -@ 32 $5."starO.Aligned.out.bam" > $5."starO.Aligned.sortedByCoord.out.bam"
rm $5."starO.Aligned.out.bam"

