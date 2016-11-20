#!/usr/bin/env bash

# Collection of fastx QC utilities for DNA Subway
# Scripts at /opt/scripts/fastx

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }

JOB=${jobName}
SEQ1="${seq1}"
TQUAL=${quality_threshold}
MINLEN=${min_length}
QTRIM=
if [[ -n $TQUAL ]] || [[ -n $MINLEN ]]; then
    echoerr "Trimming requested: $TQUAL quality / $MINLEN min length"
    QTRIM=1
fi

# fastx quality filter
MQUAL=${min_quality}
MPERCENT=${percent_bases}
QFILT=
if [[ -n $MQUAL ]] || [[ -n $MPERCENT ]]; then
    echoerr "Quality filtering requested: $MQUAL quality / $MPERCENT pct bases"
    QFILT=1
fi

INDEXING=${perform_indexing}
OUTDIR=fastx_out
mkdir -p $OUTDIR

infile=$(basename "$SEQ1")
outfile=${infile/\.*/}
outfile="${OUTDIR}/$outfile";

# Is our fastq file zipped?
# either way, we'll compress the output file..
zipper=gzip
if [[ "$infile" =~ ".gz" ]]; then
    echoerr "Decompressing $infile with $zipper"
    $zipper -d "$infile"
    infile=${infile//.gz/}
fi
if [[ "$infile" =~ ".bz2" ]]; then
    zipper=bzip2
    echoerr "Decompressing $infile with $zipper"
    $zipper -d "$infile"
    infile=${infile//.bz2/}
fi
basename="$infile";

if [[ -n "$INDEXING" && ( $INDEXING == "1" || $INDEXING == "true" ) ]]; then

    echo "Indexing..."
    indexed_file="${outfile}-idx.fastq"
    perl /opt/scripts/fastx/reindex_fq.pl $infile > $indexed_file
    echo $indexed_file
    sleep 1
    mv $indexed_file $infile
    echo $infile
    echo "Done"

fi

ARGS=

# are we Sanger or not?
Q=$(perl /opt/scripts/fastx/check_qual_score.pl "$infile")

if [[ -n $Q ]]; then
    echoerr "Quality scaling is $Q";
    ARGS=$Q;
fi


if [[ -n $QTRIM ]]; then
    if [[ -n $TQUAL ]]; then
	   LARGS="$ARGS -t $TQUAL"
    fi
    if [[ -n $MINLEN ]]; then
	   LARGS="$LARGS -l $MINLEN"
    fi

    outfile="${outfile}.qtrim"
    echoerr "Running fastq_quality_trimmer $LARGS -i $infile -o ${outfile}..."
    fastq_quality_trimmer $LARGS -i "$infile" -o "$outfile"
    echoerr "Done"
    infile="$outfile"

    LARGS=''
fi

if [[ -n $QFILT ]]; then
    if [[ -n $MQUAL ]]; then
        LARGS="$ARGS -q $MQUAL"
    fi
    if [[ -n $MPERCENT ]]; then
        LARGS="$LARGS -p $MPERCENT"
    fi

    outfile="${outfile}.qfilt"
    echoerr "Running fastq_quality_filter $LARGS -i $infile -o ${outfile}..."
    fastq_quality_filter $LARGS -i $infile -o $outfile
    echoerr "Done"
fi

if [ -f "$outfile" ];
then
    cp $outfile ${outfile}.fq
else
    echoerr "${outfile} was never generated."
    echoerr "Copying original ${infile} to ${OUTDIR}..."
    cp $infile $OUTDIR/${infile/\.*/}.fq 
    ls ${OUTDIR}
fi

outfile="${outfile}.fq"

base=${basename/\.*/}
final_outfile="${OUTDIR}/${base}-${JOB}.fastq"
cp "$outfile" "$final_outfile"

echoerr "\n*** OUTFILE is $final_outfile\n\n"
cd $OUTDIR

file_to_check=$(basename "$final_outfile");

if  [[ -z $file_to_check  ]]; then
    echoerr "Error: The outfile $file_to_check is empty!\n";
    exit 1;
fi

if  ! [[ -e "$file_to_check"  ]]; then
    echoerr "Error: The outfile $file_to_check does not exist\n";
    exit 1;
fi

# Since we have trimmed, let's remove the length assertion
# from the sequence headers
echoerr "Removing explit read-lengths from header..."
perl -i -pe 's/Length=\d+//i' "$file_to_check"
echoerr "Done"

# Run fastqc
/opt/FastQC/fastqc --quiet -f fastq "$file_to_check"

if [[ -n $zipper ]]; then
    echoerr "compressing output file with $zipper"
    $zipper "$file_to_check"
fi

cd ..

rm -f ${OUTDIR}/${infile}
rm -f ./${basename}*
rm -fr ${OUTDIR}/*filt* ${OUTDIR}/*trim* ${OUTDIR}/*fastqc

if [ "${DEBUG}" == "1" ];
then
    set +x
fi
