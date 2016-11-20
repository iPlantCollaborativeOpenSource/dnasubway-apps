#!/usr/bin/env bash

# Cufflinks apps DNA Subway

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }
if [ "${DEBUG}" == "1" ];
then
    set -x
fi

# Hard coded output directory
output_dir="cuffmerge_out"

# The reference genome sequence
seq=${ref_seq}
JOB=${jobName}

# GTF files (from cufflinks) for merging
queries[0]=${query1}
queries[1]=${query2}
queries[2]=${query3}
queries[3]=${query4}
queries[4]=${query5}
queries[5]=${query6}
queries[6]=${query7}
queries[7]=${query8}
queries[8]=${query9}
queries[9]=${query10}
queries[10]=${query11}
queries[11]=${query12}

# Create manifest for cuffmerge
MANIFEST='manifest.txt'
touch $MANIFEST

MERGED=""
for i in $(seq 0 11)
do
    echoerr $i
    file=${queries[$i]}
    if [[ -e $file ]]; then
	    echo $file >> $MANIFEST
	    MERGED="$MERGED $file"
	    echoerr $file
    fi
done

echoerr "Inspecting list of GTF files to merge..."
lines=$(cat $MANIFEST | wc -l)
unique=$(sort -u $MANIFEST | wc -l)

# Check for duplicated file names
if ! [[ "$unique" -eq "$lines" ]]; then
    echoerr "Error: Each GTF file to be merged must have a unique filename"
    exit 1
fi
# Check for > 2 files to merge
if [[ $unique -lt 2 ]]; then
    echoerr "Error: at least two GTF files are required for merging"
    exit 1
fi

ARGS="-p $THREADS -o $output_dir -s $seq $MANIFEST";
echoerr "Command: cuffmerge ${ARGS}"
time cuffmerge ${ARGS}

MERGEDONE=$(ls -alh $output_dir)

echoerr "DONE!
$MERGEDONE
"

if [ -f "$output_dir/merged.gtf" ];
then
    mv $output_dir/merged.gtf $output_dir/${JOB}-merged.gtf
else
    echoerr "Warning: GTF $output_dir/merged.gtf was not found."
fi

echo "Merged Cufflinks transcript files: $MERGED" > $output_dir/description.txt

# Make BAM file from GTF
gtf="${output_dir}/${JOB}-merged.gtf"
sam="${output_dir}/${JOB}-merged.sam"
bam="${output_dir}/${JOB}-merged"
gtf_to_sam $gtf $sam
samtools faidx $seq
samtools view -b -h -t $seq.fai -o $bam.unsorted.bam $sam
samtools sort $bam.unsorted.bam $bam
samtools index $bam.bam

# Make gff3 file from GTF
#export PERL5LIB=${CWD}/bin/lib
gff="${output_dir}/${JOB}-merged.gff"
perl /opt/scripts/cufflinks/cufflinks_gtf2gff3.pl $gtf > $gff

rm manifest.txt

if [ "${DEBUG}" == "1" ];
then
    set +x
else
    rm -f *.gtf *.fas *.fai manifest.txt
    rm -f $output_dir/*sam $output_dir/*unsorted*
fi

