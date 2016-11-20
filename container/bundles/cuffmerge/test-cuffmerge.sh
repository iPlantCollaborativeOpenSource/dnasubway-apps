#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

# Stage in test files
for F in shared/iplant_DNA_subway/genomes/arabidopsis_thaliana/genome.fas \
		 shared/iplant_training/rna-seq_tuxedo/C_cuffmerge/hy5_rep1_transcripts.gtf \
		 shared/iplant_training/rna-seq_tuxedo/C_cuffmerge/hy5_rep2_transcripts.gtf \
		 shared/iplant_training/rna-seq_tuxedo/C_cuffmerge/WT_rep1_transcripts.gtf \
		 shared/iplant_training/rna-seq_tuxedo/C_cuffmerge/WT_rep2_transcripts.gtf
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

export ref_seq="genome.fas"
export query1="hy5_rep1_transcripts.gtf"
export query2="hy5_rep2_transcripts.gtf"
export query3="WT_rep1_transcripts.gtf"
export query4="WT_rep2_transcripts.gtf"
export jobName="testcuffmerge"
export description="Does it merge?"

DEBUG=0 TYPE=docker ./wrap-cuffmerge.sh && \
					cat cuffmerge_out/logs/run.log && \
					cat cuffmerge_out/description.txt && \
					ls -alt cuffmerge_out && \
					rm -rf cuffmerge_out

#&& ls -alth cufflinks_out && rm -rf cufflinks_out cufflinks.stderr
