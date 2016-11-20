#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

# Inputs
# Global env variable "input" is set by the wrapper script
export SEQ1="${input}"
mkdir -p wc_out
wc "$SEQ1" > wc_out/output.txt

# Cleanup
rm "$SEQ1"

if [ "${DEBUG}" == "1" ];
then
    set +x
fi
