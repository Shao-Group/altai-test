#!/usr/bin/sh

## init ##

left=$1
right=$2
out_prefix=$3
library_type=$4

rnaspades.py -o rnaSpades.$out_prefix --pe-1 0 $left --pe-2 0 $right --ss $library_type  -t 8 -k auto


