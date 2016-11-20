#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

# Inputs
# Global env variable "input" is set by the wrapper script
export SEQ1="${input}"
mkdir -p fastqc_out
/opt/FastQC/fastqc --quiet -f fastq -o fastqc_out "$SEQ1"

# Cleanup
rm "$SEQ1"

if [ "${DEBUG}" == "1" ];
then
    set +x
fi
