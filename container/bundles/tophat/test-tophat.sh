#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

# Stage in test files
for F in shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/genome.tgz \
		 shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/annotation.gtf
do
	BASENAME=$(basename $F)
	if [ -f original.${BASENAME} ];
	then
		cp original.${BASENAME} ${BASENAME}
	fi
	if [ ! -f $BASENAME ];
	then
		files-get $F && cp $F original.${BASENAME}
	fi
done
# shared/iplant_DNA_subway/sample_data/fastq/arabidopsis_thaliana/single_end/WT_rep1.fastq
if [ -f "original.WT_rep1.fastq" ];
then
	cp original.WT_rep1.fastq WT_rep1.fastq
fi

if [ ! -f "WT_rep1.fastq" ];
then
	files-get -R 0-1000000 -N temp.fq shared/iplantcollaborative/example_data/fastqc/SRR070572_hy5.fastq &&
	head -n 100000 temp.fq > original.WT_rep1.fastq && rm temp.fq && cp original.WT_rep1.fastq WT_rep1.fastq
fi

export query1="WT_rep1.fastq"
export genome="genome.tgz"
export annotation="annotation.gtf"
export no_novel_juncs=1
export max_deletion_length="3"
export splice_mismatches="0"
export min_anchor_length="8"
export segment_length="25"
export jobName="tophat"
export min_isoform_fraction="0.15"
export read_mismatches="2"
export max_insertion_length="3"
export max_multihits="20"
export bowtie_version="2"
export min_intron_length="70"
export library_type="fr-unstranded"
export max_intron_length="50000"

DEBUG=1 TYPE=docker ./wrap-tophat.sh && ls tophat_out && cat tophat_out/flagstat_out.txt && rm -rf tophat_out *stderr
