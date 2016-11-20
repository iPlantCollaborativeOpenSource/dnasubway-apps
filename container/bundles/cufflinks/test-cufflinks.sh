#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

# Stage in test files
for F in vaughn/dnalc/docker/cufflinks-input.bam \
		 shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/genome.fas \
		 shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/annotation.gtf
do
	BASENAME=$(basename $F)
	
	if [ -f ${BASENAME}.original ];
	then
		echo "Copying over $BASENAME ..."
		cp ${BASENAME}.original ${BASENAME}
	fi

	if [ ! -f $BASENAME ];
	then
		echo "Downloading $BASENAME ..."
		iget -rPT /iplant/home/$F . && cp ${BASENAME} ${BASENAME}.original
		#files-get $F && cp ${BASENAME} original.${BASENAME}
	fi

done

export query1="cufflinks-input.bam"
export annotation="annotation.gtf"
export BIAS_FASTA="genome.fas"
export compatibleHitsNorm="0"
export gtf="0"
export guide_gtf="1"
export intronOverhangTolerance="50"
export jobName="cufflinkstest"
export libraryType="fr-firststrand"
export maxBundleLength="3500000"
export maxIntronLength="300000"
export minFragsPerTransfrag="10"
export minIntronLength="50"
export minIsoformFraction="0.1"
export multiReadCorrect="0"
export noFauxReads="0"
export overhangTolerance="10"
export overhangTolerance3="600"
export preMrnaFraction="0.15"
export smallAnchorFraction="0.09"
export totalHitsNorm="1"
export trim3avgcovThresh="10"
export trim3dropoffFrac="0.1"
export upperQuartileNorm="0"

DEBUG=1 TYPE=docker ./wrap-cufflinks.sh && ls -alth cufflinks_out && rm -rf cufflinks_out cufflinks.stderr
