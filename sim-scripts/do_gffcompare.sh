#!/usr/bin/sh

# compare assembly methods after running each method or pipeline 


al1_gtf=$1
al2_gtf=$2
al1sp_gtf=$3
al2sp_gtf=$4
nonsp_gtf=$5
merged_gtf=$6

prefix=$7

altai_dir=$8
scallop_dir=$9

d="gffcpr"
if [ ! -d $d  ]
then
	mkdir $d
fi

gffcompare -r $al1_gtf     -o $d/$prefix.allele1.altai      $altai_dir/altai.$prefix.allele1.gtf
gffcompare -r $al2_gtf     -o $d/$prefix.allele2.altai      $altai_dir/altai.$prefix.allele2.gtf
gffcompare -r $al1sp_gtf   -o $d/$prefix.allele1spec.altai  $altai_dir/altai.$prefix.allele1spec.multi-exon.gtf
gffcompare -r $al2sp_gtf   -o $d/$prefix.allele2spec.altai  $altai_dir/altai.$prefix.allele2spec.multi-exon.gtf
gffcompare -r $nonsp_gtf   -o $d/$prefix.nonspec.altai      $altai_dir/altai.$prefix.nonspec.multi-exon.gtf
gffcompare -r $merged_gtf  -o $d/$prefix.merged.altai       $altai_dir/altai.$prefix.merged.gtf


gffcompare -r $al1_gtf     -o $d/$prefix.allele1.sc2      $scallop_dir/scallop2.$prefix.allele1.gtf
gffcompare -r $al2_gtf     -o $d/$prefix.allele2.sc2      $scallop_dir/scallop2.$prefix.allele2.gtf
gffcompare -r $al1sp_gtf   -o $d/$prefix.allele1spec.sc2  $scallop_dir/scallop2.$prefix.allele1spec.gtf
gffcompare -r $al2sp_gtf   -o $d/$prefix.allele2spec.sc2  $scallop_dir/scallop2.$prefix.allele2spec.gtf
gffcompare -r $nonsp_gtf   -o $d/$prefix.nonspec.sc2      $scallop_dir/scallop2.$prefix.nonspec.gtf
gffcompare -r $merged_gtf  -o $d/$prefix.merged.sc2       $scallop_dir/scallop2.$prefix.gtf



