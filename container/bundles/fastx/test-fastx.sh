#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

cp original.sample.fq sample.fastq
export seq1="sample.fastq"
export jobName="testfastx"
export min_quality="20"
export quality_threshold="20"
export percent_bases="50"
export min_length="20"
export perform_indexing="0"

DEBUG=1 TYPE=docker ./wrap-fastx.sh && ls fastx_out && sleep 1 && rm -rf fastx_out && rm -f _* .agave.archive
