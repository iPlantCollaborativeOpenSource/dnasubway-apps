#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

# Stage in test files
for F in vaughn/dnalc/ghiban/DNASubway/project-389/cl2576/cufflinks_out/WT_rep1-th2552-cl2576.gtf \
		 vaughn/dnalc/ghiban/DNASubway/project-389/cl2577/cufflinks_out/WT_rep2-th2553-cl2577.gtf \
		 vaughn/dnalc/ghiban/DNASubway/project-389/cl2574/cufflinks_out/ra1_rep1-th2550-cl2574.gtf \
		 vaughn/dnalc/ghiban/DNASubway/project-389/cl2575/cufflinks_out/ra1_rep2-th2551-cl2575.gtf \
		 vaughn/dnalc/ghiban/DNASubway/project-389/th2550/tophat_out/ra1_rep1-th2550.bam \
		 vaughn/dnalc/ghiban/DNASubway/project-389/th2552/tophat_out/WT_rep1-th2552.bam \
		 vaughn/dnalc/ghiban/DNASubway/project-389/th2553/tophat_out/WT_rep2-th2553.bam \
		 vaughn/dnalc/ghiban/DNASubway/project-389/th2551/tophat_out/ra1_rep2-th2551.bam \
		 shared/iplant_DNA_subway/genomes/zea_mays/genome.fas \
 		 shared/iplant_DNA_subway/genomes/zea_mays/annotation.gtf
do
	BASENAME=$(basename $F)
	
	if [ -f ${BASENAME}.original ];
	then
		echo "Copying over $BASENAME ..."
		if [ ! -f ${BASENAME} ]; then cp ${BASENAME}.original ${BASENAME}; fi
	fi

	if [ ! -f $BASENAME ];
	then
		echo "Downloading $BASENAME ..."
		iget -rPT /iplant/home/$F . && cp ${BASENAME} ${BASENAME}.original
		#files-get $F && cp ${BASENAME} original.${BASENAME}
	fi

done

# inputs
export query1="WT_rep1-th2552-cl2576.gtf"
export query2="WT_rep2-th2553-cl2577.gtf"
export query3="ra1_rep1-th2550-cl2574.gtf"
export ref_gtf="annotation.gtf"
export query5="ra1_rep2-th2551-cl2575.gtf"
export sam2_f1="ra1_rep1-th2550.bam"
export sam1_f1="WT_rep1-th2552.bam"
export sam1_f2="WT_rep2-th2553.bam"
export sam2_f2="ra1_rep2-th2551.bam"
export ref_seq="genome.fas"
# parameters
export min_isoform_Fraction="0.1"
export skipCuffmerge="0"
export fragLenMean="200"
export libraryType="fr-firststrand"
export labels="sample1,sample2"
export compatibleHitsNorm="0"
export treatAsTimeSeries="0"
export refGTF="1"
export fragLenStdev="80"
export totalHitsNorm="1"
export fdr="0.05"
export poissonDispersion="0"
export upperQuartileNorm="0"
export minAlignmentCount="10"
export multiReadCorrect="0"
export species="zea_mays"
export jobName="cuffdiff"

DEBUG=1 TYPE=docker ./wrap-cuffdiff.sh 

