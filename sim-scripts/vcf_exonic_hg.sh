# filter vcf to exonic vcf by bedtools

# input:
# $1 = gtf file
# $2 = vcf

# output:
# $3 = output vcf name
# $4 = output gtf name

# vcf change chr name & keep minimal info
echo "##fileformat=VCFv4.2" > $3.SNP.vcf
 
# exonic gtf, group exons to consecutive lines by position
awk '{if ($3 == "exon") print $0; }' $1 | sort -k 1 -k 4,5n | uniq > "tmp.exonic.gtf" 

# keep exons w. vcf
# column 1-9 gtf, column 10+ vcf
bedtools intersect -a "tmp.exonic.gtf" -b $3.SNP.vcf -wa -wb > intersect.exons_and_vcf

# filter gtf to keep transcripts with variants
cut -f 1-9 intersect.exons_and_vcf > "tmp".intersect.exons.gtf
python ../sim-scripts/gtf_filter_by.py $1 "tmp".intersect.exons.gtf transcript_id > $4

# filter and random select one variation per exon
# exon is defined as position (regardless of parents or strand)
python ../sim-scripts/vcf_bedtools_wa_wb.py intersect.exons_and_vcf > $3."intersect.selected.vcf"




mv intersect.exons_and_vcf tmp
rm "tmp.exonic.gtf"
rm "tmp".intersect.exons.gtf
