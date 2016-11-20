#!/usr/bin/env bash

# Cufflinks apps DNA Subway

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }
if [ "${DEBUG}" == "1" ];
then
    set -x
fi

OUTPUT_DIR=cuffdiff_out

JOB=${jobName}

QUERY1=${query1}
QUERY2=${query2}
QUERY3=${query3}
QUERY4=${query4}
QUERY5=${query5}
QUERY6=${query6}
QUERY7=${query7}
QUERY8=${query8}
QUERY9=${query9}
QUERY10=${query10}
QUERY11=${query11}
QUERY12=${query12}
SAM1_F1=${sam1_f1}
SAM1_F2=${sam1_f2}
SAM1_F3=${sam1_f3}
SAM1_F4=${sam1_f4}
SAM2_F1=${sam2_f1}
SAM2_F2=${sam2_f2}
SAM2_F3=${sam2_f3}
SAM2_F4=${sam2_f4}
SAM3_F1=${sam3_f1}
SAM3_F2=${sam3_f2}
SAM3_F3=${sam3_f3}
SAM3_F4=${sam3_f4}
SAM4_F1=${sam4_f1}
SAM4_F2=${sam4_f2}
SAM4_F3=${sam4_f3}
SAM4_F4=${sam4_f4}
SAM5_F1=${sam5_f1}
SAM5_F2=${sam5_f2}
SAM5_F3=${sam5_f3}
SAM5_F4=${sam5_f4}
SAM6_F1=${sam6_f1}
SAM6_F2=${sam6_f2}
SAM6_F3=${sam6_f3}
SAM6_F4=${sam6_f4}
SAM7_F1=${sam7_f1}
SAM7_F2=${sam7_f2}
SAM7_F3=${sam7_f3}
SAM7_F4=${sam7_f4}
SAM8_F1=${sam8_f1}
SAM8_F2=${sam8_f2}
SAM8_F3=${sam8_f3}
SAM8_F4=${sam8_f4}
SAM9_F1=${sam9_f1}
SAM9_F2=${sam9_f2}
SAM9_F3=${sam9_f3}
SAM9_F4=${sam9_f4}
SAM10_F1=${sam10_f1}
SAM10_F2=${sam10_f2}
SAM10_F3=${sam10_f3}
SAM10_F4=${sam10_f4}
REF_GTF=${ref_gtf}
MASK_GTF=${mask_gtf}
REF_SEQ=${ref_seq}
# parameters
JOBNAME=${jobName}
MIN_ISOFORM_FRACTION=${min_isoform_Fraction}
LABELS=${labels}
TREATASTIMESERIES=${treatAsTimeSeries}
SPECIES=${species}
POISSONDISPERSION=${poissonDispersion}
MULTIREADCORRECT=${multiReadCorrect}
UPPERQUARTILENORM=${upperQuartileNorm}
TOTALHITSNORM=${totalHitsNorm}
COMPATIBLEHITSNORM=${compatibleHitsNorm}
LIBRARYTYPE=${libraryType}
MINALIGNMENTCOUNT=${minAlignmentCount}
FDR=${fdr}
FRAGLENMEAN=${fragLenMean}
FRAGLENSTDEV=${fragLenStdev}
REFGTF=${refGTF}
SKIPCUFFMERGE=${skipCuffmerge}
# outputs

MANIFEST=gtf_to_merge.txt
rm -rf $MANIFEST && touch $MANIFEST
if [[ -n $QUERY1  ]]; then echo $QUERY1  >> $MANIFEST; fi
if [[ -n $QUERY2  ]]; then echo $QUERY2  >> $MANIFEST; fi
if [[ -n $QUERY3  ]]; then echo $QUERY3  >> $MANIFEST; fi
if [[ -n $QUERY4  ]]; then echo $QUERY4  >> $MANIFEST; fi
if [[ -n $QUERY5  ]]; then echo $QUERY5  >> $MANIFEST; fi
if [[ -n $QUERY6  ]]; then echo $QUERY6  >> $MANIFEST; fi
if [[ -n $QUERY7  ]]; then echo $QUERY7  >> $MANIFEST; fi
if [[ -n $QUERY8  ]]; then echo $QUERY8  >> $MANIFEST; fi
if [[ -n $QUERY9  ]]; then echo $QUERY9  >> $MANIFEST; fi
if [[ -n $QUERY10 ]]; then echo $QUERY10 >> $MANIFEST; fi
if [[ -n $QUERY11 ]]; then echo $QUERY11 >> $MANIFEST; fi
if [[ -n $QUERY12 ]]; then echo $QUERY12 >> $MANIFEST; fi

if [[ $SKIPCUFFMERGE -eq 1 ]]; then
    echoerr "Skipping Cuffmerge"
else
    echoerr "*** Inspecting list of GTF files to merge... ***"
    lines=$(cat $MANIFEST | wc -l)
    unique=$(sort -u $MANIFEST | wc -l)

    if ! [[ $unique -eq $lines ]]; then
        echoerr "Error: Each GTF file to be merged must have a unique filename"
        exit 1
    fi

    if [[ $unique -lt 2 ]]; then
        echoerr "Error: at least two GTF files are required for merging"
        exit 1
    fi

    if [[ $USEGTF -eq 1 ]]; then
        INCLUDE_REF_GTF=" -g $REFGTF "
        echoerr "Reference GTF being used at Cuffmerge"
    else
        INCLUDE_REF_GTF=""
        echoerr "No reference GTF being used at Cuffmerge"
    fi

    ARGS="-p $THREADS -o cuffmerge_out $INCLUDE_REF_GTF -s $REF_SEQ $MANIFEST";

    echoerr "Command: cuffmerge ${ARGS}"
    time cuffmerge $ARGS

    echoerr "*** Done with cuffmerge *** "

    MERGEDONE=$(ls -alh cuffmerge_out)
    echoerr "
    $MERGEDONE
    "

    ANNOTATION='./cuffmerge_out/merged.gtf'
    if [[ ! -e $ANNOTATION ]]; then
        echoerr "No point going on, cuffmerge failed ($ANNOTATION is missging)."
        exit 1
    fi
fi

if [[ -z $ANNOTATION ]]; then
    ANNOTATION=$REFGTF
fi

# not supported/recommended
#poissonDispersion=${poissonDispersion}

# Mandatory parameters
# --min-alignment-count 10
MINALIGNMENTCOUNT=${minAlignmentCount}
# --FDR 0.05
FDR=${fdr}
# Force Replace spaces with empty characters
LABELS=${labels}
LABELS=${LABELS//\ /}

# --library-type fr-unstranded
LIBRARYTYPE=${libraryType}

# Optional
# --frag-len-mean 200
FRAGLENMEAN=${fragLenMean}
# --frag-len-std-dev 80
FRAGLENSTDEV=${fragLenStdev}

# Fetch alignment files
if [[ -e "$SAM1_F1" ]]; then SAM1_F=$SAM1_F1; echo "$SAM1_F found"
else echoerr "$SAM1_F is missing! Abort!"; exit 1; fi

if [[ -n $SAM1_F2 ]]; then SAM1_F="$SAM1_F,$SAM1_F2"; fi
if [[ -n $SAM1_F3 ]]; then SAM1_F="$SAM1_F,$SAM1_F3"; fi
if [[ -n $SAM1_F4 ]]; then SAM1_F="$SAM1_F,$SAM1_F4"; fi
echoerr "SAM1 files $SAM1_F"

if [[ -n $SAM2_F1 ]]; then SAM2_F="$SAM2_F1"        ; fi
if [[ -n $SAM2_F2 ]]; then SAM2_F="$SAM2_F,$SAM2_F2"; fi
if [[ -n $SAM2_F3 ]]; then SAM2_F="$SAM2_F,$SAM2_F3"; fi
if [[ -n $SAM2_F4 ]]; then SAM1_F="$SAM2_F,$SAM2_F4"; fi
echoerr "SAM2 files $SAM2_F"

if [[ -n $SAM3_F1 ]]; then SAM3_F="$SAM3_F1"        ; fi
if [[ -n $SAM3_F2 ]]; then SAM3_F="$SAM3_F,$SAM3_F2"; fi
if [[ -n $SAM3_F3 ]]; then SAM3_F="$SAM3_F,$SAM3_F3"; fi
if [[ -n $SAM3_F4 ]]; then SAM3_F="$SAM3_F,$SAM3_F4"; fi
echoerr "SAM3 Files $SAM3_F"

if [[ -n $SAM4_F1 ]]; then SAM4_F="$SAM4_F1"        ; fi
if [[ -n $SAM4_F2 ]]; then SAM4_F="$SAM4_F,$SAM4_F2"; fi
if [[ -n $SAM4_F3 ]]; then SAM4_F="$SAM4_F,$SAM4_F3"; fi
if [[ -n $SAM4_F4 ]]; then SAM4_F="$SAM4_F,$SAM4_F4"; fi

if [[ -n $SAM5_F1 ]]; then SAM5_F="$SAM5_F1"        ; fi
if [[ -n $SAM5_F2 ]]; then SAM5_F="$SAM5_F,$SAM5_F2"; fi
if [[ -n $SAM5_F3 ]]; then SAM5_F="$SAM5_F,$SAM5_F3"; fi
if [[ -n $SAM5_F4 ]]; then SAM5_F="$SAM5_F,$SAM5_F4"; fi

if [[ -n $SAM6_F1 ]]; then SAM6_F="$SAM6_F1"        ; fi
if [[ -n $SAM6_F2 ]]; then SAM6_F="$SAM6_F,$SAM6_F2"; fi
if [[ -n $SAM6_F3 ]]; then SAM6_F="$SAM6_F,$SAM6_F3"; fi
if [[ -n $SAM6_F4 ]]; then SAM6_F="$SAM6_F,$SAM6_F4"; fi

if [[ -n $SAM7_F1 ]]; then SAM7_F="$SAM7_F1"        ; fi
if [[ -n $SAM7_F2 ]]; then SAM7_F="$SAM7_F,$SAM7_F2"; fi
if [[ -n $SAM7_F3 ]]; then SAM7_F="$SAM7_F,$SAM7_F3"; fi
if [[ -n $SAM7_F4 ]]; then SAM7_F="$SAM7_F,$SAM7_F4"; fi

if [[ -n $SAM8_F1 ]]; then SAM8_F="$SAM8_F1"        ; fi
if [[ -n $SAM8_F2 ]]; then SAM8_F="$SAM8_F,$SAM8_F2"; fi
if [[ -n $SAM8_F3 ]]; then SAM8_F="$SAM8_F,$SAM8_F3"; fi
if [[ -n $SAM8_F4 ]]; then SAM8_F="$SAM8_F,$SAM8_F4"; fi

if [[ -n $SAM9_F1 ]]; then SAM9_F="$SAM9_F1"        ; fi
if [[ -n $SAM9_F2 ]]; then SAM9_F="$SAM9_F,$SAM9_F2"; fi
if [[ -n $SAM9_F3 ]]; then SAM9_F="$SAM9_F,$SAM9_F3"; fi
if [[ -n $SAM9_F4 ]]; then SAM9_F="$SAM9_F,$SAM9_F4"; fi

if [[ -n $SAM10_F1 ]]; then SAM10_F="$SAM10_F1"         ; fi
if [[ -n $SAM10_F2 ]]; then SAM10_F="$SAM10_F,$SAM10_F2"; fi
if [[ -n $SAM10_F3 ]]; then SAM10_F="$SAM10_F,$SAM10_F3"; fi
if [[ -n $SAM10_F4 ]]; then SAM10_F="$SAM10_F,$SAM10_F4"; fi

# Initialize OPTIONS with mandatory parameters
OPTIONS="--no-update-check --num-threads ${THREADS} --output-dir ${OUTPUT_DIR}"
OPTIONS="$OPTIONS --library-type ${LIBRARYTYPE} --min-alignment-count ${MINALIGNMENTCOUNT} --labels ${LABELS}"

# Flag  OPTIONS
if   [[ "${treatAsTimeSeries}"  -eq 1 ]]; then OPTIONS="${OPTIONS} --time-series"              ; fi
if   [[ "${multiReadCorrect}"   -eq 1 ]]; then OPTIONS="${OPTIONS} --multi-read-correct"       ; fi
if   [[ "${upperQuartileNorm}"  -eq 1 ]]; then OPTIONS="${OPTIONS} --upper-quartile-norm"      ; fi
if   [[ "${totalHitsNorm}"      -eq 1 ]]; then OPTIONS="${OPTIONS} --total-hits-norm"
elif [[ "${compatibleHitsNorm}" -eq 1 ]]; then OPTIONS="${OPTIONS} --compatible-hits-norm"     ; fi
if   [[ "${poissonDispersion}"  -eq 1 ]]; then OPTIONS="${OPTIONS} --dispersion-method poisson"; fi

# Parameter OPTIONS
# JMF note: these next few line can't be working as intended.
if [[ -n "${FRAGLENMEAN}" ]]; then
    OPTIONS="${OPTIONS} --frag-len-mean ${FRAGLENMEAN}"
fi
if [[ -n "${FRAGLENSTDEV}" ]]; then
    OPTIONS="${OPTIONS} --frag-len-std-dev ${FRAGLENSTDEV}"
fi

if [[ -n "$fdr" ]]     ; then OPTIONS="${OPTIONS} --FDR $fdr"    ; fi
if [[ -n "$REFSEQ_F" ]]; then OPTIONS="${OPTIONS} -b ${REFSEQ_F}"; fi

# and we pull the trigger...
SAMS="${SAM1_F} ${SAM2_F} ${SAM3_F} ${SAM4_F} ${SAM5_F} ${SAM6_F} ${SAM7_F} ${SAM8_F} ${SAM9_F} ${SAM10_F}"
echoerr "$SAMS"
echoerr "$(ls -al *.bam *.gtf)"
echoerr "Command: cuffdiff ${OPTIONS} ${ANNOTATION} $SAMS"

time cuffdiff ${OPTIONS} ${ANNOTATION} $SAMS 2>cuffdiff.stderr

if ! [[ -d $OUTPUT_DIR ]]; then
  echoerr "Oh no, cuffdiff failed!  I quit."
  exit 1
fi

echoerr "Preparing global R plots..."
  perl /opt/scripts/cufflinks/cuffdiff_R_plots.pl $LABELS
echoerr "Sorting output data..."

# Get the biomart annotations
wget --tries=10 "https://agave.iplantc.org/files/v2/download/ghiban/system/data.iplantcollaborative.org/shared/iplant_DNA_subway/genomes/${species}/${species}.txt"

if [[ -e ${species}.txt ]]; then
        echoerr "BioMart annotations exist, grabbing them, then running cuffdiff_sort.pl"
        perl /opt/scripts/cufflinks/cuffdiff_sort.pl /home $LABELS ${species}
else
        echoerr "BioMart annotations do not exist, running cuffdiff_sort.pl without them"
        perl /opt/scripts/cufflinks/cuffdiff_sort.pl /home $LABELS
fi

echoerr "Done!"

if [ "${DEBUG}" == "1" ];
then
    set +x
else
    echo "Cleaning up"
fi

