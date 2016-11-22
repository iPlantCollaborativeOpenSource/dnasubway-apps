#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

# Stage in test files
for F in shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/genome.fas
do
	BASENAME=$(basename $F)
	if [ -f original.${BASENAME} ];
	then
		cp original.${BASENAME} ${BASENAME}
	fi
	if [ ! -f $BASENAME ];
	then
		iget -rPT /iplant/home/$F . && cp ${BASENAME} original.${BASENAME}
	fi
done

export referenceFasta="genome.fas"
export cleanupParameter=1

DEBUG=1 TYPE=docker ./wrap-tophat-refprep.sh && ls 
