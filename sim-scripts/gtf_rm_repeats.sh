# input:
# $1 = gtf file
# $2 = repeat bed file

# output:
# $3 =  output genome name


# substitute accession number to chr name
# AE014134.6	chr2L
# AE013599.5	chr2R
# AE014296.5 	chr3L
# AE014297.3 	chr3R
# AE014135.4 	chr4
# AE014298.5	chrX
awk '{gsub(/^AE014134.6/, "chr2L"); gsub(/^AE013599.5/, "chr2R"); gsub(/^AE014296.5/, "chr3L");
      gsub(/^AE014297.3/, "chr3R"); gsub(/^AE014135.4/, "chr4"); gsub(/^AE014298.5/, "chrX"); 
      print;}' $1 | grep '^#\|^chr' > $3".gtf" 


# format & cut bed keep
cut -f 2-10 $2 > "tmp".repeat.bed


# remove gene overlapping repeats and containing > 10 SNPs
awk '{if ($3 == "gene") print $0; }' $3".gtf"  > "tmp".$3."gene_level.gtf"
bedtools intersect -v -a "tmp".$3."gene_level.gtf" -b "tmp".repeat.bed > $3

#rm "tmp".$3."chrname.gtf" "tmp".$3."gene_level.gtf" "tmp".repeat.bed

