#!/usr/bin/env bash

# Tophat align and refprep for DNA Subway
# Scripts at /opt/scripts/tophat

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }
if [ "${DEBUG}" == "1" ];
then
    set -x
fi

# This is old-style parameter setting
QUERY1=${query1}
QUERY2=${query2}
GENOME=${genome}
GTF=${annotation}
JOB=${jobName}
output_dir=tophat_out
Mate_inner_dist=${mate_inner_dist}
Mate_std_dev=${mate_std_dev}
Min_anchor_length=${min_anchor_length}
Splice_mismatches=${splice_mismatches}
Min_intron_length=${min_intron_length}
Max_intron_length=${max_intron_length}
Max_insertion_length=${max_insertion_length}
Max_deletion_length=${max_deletion_length}
Min_isoform_fraction=${min_isoform_fraction}
Max_multihits=${max_multihits}
Segment_length=${segment_length}
Library_type=${library_type}
Read_mismatches=${read_mismatches}
No_novel_juncs=${no_novel_juncs}

date1=$(date +"%s")

# untar reference bundle
tar -xvf ${GENOME}
# Handle both tgz and tar archives, albeit a touch inelegantly
ref=$(echo "$GENOME" | sed 's/.tgz//g' | sed 's/.tar//g')
GENOME_F=${ref}.fa
# This is to work around Bowtie silliness. .fas is a valid extension for Fasta files!!!
ln -s $GENOME_F ${GENOME_F}.fa;

# Quick sanity check before committing to do anything compute intensive
if ! [ -e $GENOME_F ]; then
  echo "Error: Genome sequence not found."
  exit 1
fi

# Determine pair-end or not
PE=0
if [[ -n $QUERY1 ]] && [[ -n $QUERY2 ]]; then let PE=1; echo "Paired-end"; fi

# Query sequences
QUERY1_F=$(basename ${QUERY1})

if [[ "$QUERY1_F" =~ ".gz" ]]; then
    echoerr "Decompressing $QUERY1_F with gunzip"
    gunzip $QUERY1_F;
    QUERY1_F=${QUERY1_F//.gz/}
elif [[ "$QUERY1_F" =~ ".bz2" ]]; then
    echoerr "Decompressing $QUERY1_F with bunzip2"
    bunzip2 $QUERY1_F;
    QUERY1_F=${QUERY1_F//.bz2/}
fi

QUERY2_F=
if [ "$PE" = "1" ]; then
    QUERY2_F=$(basename ${QUERY2})

    if [[ "$QUERY2_F" =~ ".gz" ]]; then
        echoerr "Decompressing $QUERY2_F with gunzip"
        gunzip $QUERY2_F;
        QUERY2_F=${QUERY2_F//.gz/}
    elif [[ "$QUERY2_F" =~ ".bz2" ]]; then
        echoerr "Decompressing $QUERY2_F with bunzip2"
        bunzip2 $QUERY2_F;
        QUERY2_F=${QUERY2_F//.bz2/}
    fi

    perl /opt/scripts/tophat/resynch_paired_reads.pl $QUERY1_F $QUERY2_F
    find2perl . -name '*_synched' -eval 'my $o=$_; $_=~s/_synched$//;rename $o, $_;'|perl

fi

GTF_F=
if [[ -n $GTF ]]; then
    GTF_F=$(basename ${GTF})
fi

# Are we Sanger quals or...
QUAL=$(perl /opt/scripts/tophat/check_qual_score.pl $QUERY1_F)
if [[ -n $QUAL ]]; then
    echoerr "Quality scaling is $QUAL"
fi

ARGS="--num-threads $THREADS --output-dir $output_dir"
if [[ -n $QUAL ]];then
    ARGS="$ARGS $QUAL"
fi

if [ "$PE" = "1" ]; then
    if [[ -n $Mate_inner_dist  ]];then
        ARGS="$ARGS --mate-inner-dist $Mate_inner_dist"
    fi
    if [[ -n $Mate_std_dev  ]];then
        ARGS="$ARGS --mate-std-dev $Mate_std_dev"
    fi
fi

if [[ -n $Min_anchor_length  ]];then
    ARGS="$ARGS --min-anchor-length $Min_anchor_length"
fi
if [[ -n $Splice_mismatches  ]];then
    ARGS="$ARGS --splice-mismatches $Splice_mismatches"
fi
if [[ -n $Min_intron_length  ]];then
    ARGS="$ARGS --min-intron-length $Min_intron_length"
fi
if [[ -n $Max_intron_length  ]];then
    ARGS="$ARGS --max-intron-length $Max_intron_length"
fi
if [[ -n $Max_insertion_length  ]];then
    ARGS="$ARGS  --max-insertion-length $Max_insertion_length"
fi
if [[ -n $Max_deletion_length  ]];then
    ARGS="$ARGS --max-deletion-length $Max_deletion_length"
fi
if [[ -n $Min_isoform_fraction  ]];then
    ARGS="$ARGS --min-isoform-fraction $Min_isoform_fraction"
fi
if [[ -n $Max_multihits  ]];then
    ARGS="$ARGS --max-multihits $Max_multihits"
fi
if [[ -n  $Library_type ]];then
    ARGS="$ARGS --library-type $Library_type"
fi
if [[ -n $Segment_length  ]];then
    ARGS="$ARGS --segment-length $Segment_length"
fi
if [[ -n $Read_mismatches  ]];then
    ARGS="$ARGS --read-mismatches $Read_mismatches"
fi
if [[ -n $GTF_F  ]];then
    ARGS="$ARGS -G $GTF_F"
fi
if [[ -n $No_novel_juncs ]] && [ $No_novel_juncs == 1 ]; then
    ARGS="${ARGS} --no-novel-juncs"
fi

ARGS="$ARGS $GENOME_F $QUERY1_F $QUERY2_F"

echoerr "Executing tophat $ARGS\n"

tophat $ARGS 2> tophat.stderr
exit_code=$?
echoerr "Done with exit code: $exit_code!"

if ! [[ -d $output_dir ]]; then
    echo "ERROR: output dir $output_dir not found"
     
    exit 1
fi
if ! [[ -f $output_dir/accepted_hits.bam ]]; then
    echo "ERROR: output files not found in $output_dir"
    
    exit 1
fi

samtools sort  "$output_dir/accepted_hits.bam" "$output_dir/accepted_hits_sorted"
samtools index "$output_dir/accepted_hits_sorted.bam"
samtools flagstat "$output_dir/accepted_hits_sorted.bam" > "$output_dir/flagstat_out.txt"
samtools idxstats "$output_dir/accepted_hits_sorted.bam" > "$output_dir/idxstats_out.txt"

realName=""
if [ "$PE" = "1" ]; then
    realName=$(perl /opt/scripts/tophat/build_name.pl $QUERY1_F $QUERY2_F)
else
    name=${QUERY1_F/\.*/}
    realName=${name/_processed_reads/}
fi

mv "$output_dir/accepted_hits_sorted.bam" "$output_dir/${realName}-${JOB}.bam"
mv "$output_dir/accepted_hits_sorted.bam.bai" "$output_dir/${realName}-${JOB}.bam.bai"

# Final steps
find tophat_out/ -maxdepth 1 -type f -exec md5sum {} \; > $output_dir/MD5SUM.txt

date2=$(date +"%s")
diff=$(($date2-$date1))

echoerr "\n$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.\n"

# Cleanup
rm -rf ${GENOME} ${GTF} ${GENOME_F}* $GTF_F *.fa *.bt2 $QUERY1_F $QUERY2_F $output_dir/accepted_hits.bam genome.dict 

if [ "${DEBUG}" == "1" ];
then
    set +x
fi
