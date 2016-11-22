#!/bin/bash

echo "Cleaning job files and other cruft..."

while read X
do
	echo "  $X files"
	find . -name "$X" -exec rm {} \;
done <<CLEAN
.built.*
*.img
*.img.bz2
genome.*
annotation.*
original.*
*.original
*.gz
*.bz2
*.tgz
*.zip
*.fai
*.fa
*.fasta
*.fas
*.fq
*.fastq
*.bam
*.bai
*.zip
*.env
*.variables
*.singularity
*.stderr
*_out
CLEAN
