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


# repeat bed format & cut 
cut -f 2-10 $2 > "tmp".repeat.bed

# fine gene w/o overlapping repeats 
# remove gene Dmel_CG32491 which appears in multiple locations with the same id. It could introduce a problem if identificatiof genes are based on id
awk '{if ($3 == "gene") print $0; }' $3".gtf" | grep -v 'gene_id "Dmel_CG32491"' > "tmp".$3."gene_level.gtf"
bedtools intersect -v -a "tmp".$3."gene_level.gtf" -b "tmp".repeat.bed > "tmp".$3.norepeat_gene.gtf

# keep according to name
python ../sim-scripts/gtf_filter_by.py dm6.gtf "tmp".$3.norepeat_gene.gtf gene_id  > dm6.norepeat.gtf




rm "tmp".$3."gene_level.gtf" 
rm "tmp".repeat.bed
rm "tmp".$3.norepeat_gene.gtf

