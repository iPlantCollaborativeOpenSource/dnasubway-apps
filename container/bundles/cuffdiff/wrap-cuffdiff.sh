#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

APPNAME=cuffdiff
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"

rm -rf "$DOCK_ENV*"

# inputs
echo "query1=${query1}" >> ${DOCK_ENV}
echo "query2=${query2}" >> ${DOCK_ENV}
echo "query3=${query3}" >> ${DOCK_ENV}
echo "query4=${query4}" >> ${DOCK_ENV}
echo "query5=${query5}" >> ${DOCK_ENV}
echo "query6=${query6}" >> ${DOCK_ENV}
echo "query7=${query7}" >> ${DOCK_ENV}
echo "query8=${query8}" >> ${DOCK_ENV}
echo "query9=${query9}" >> ${DOCK_ENV}
echo "query10=${query10}" >> ${DOCK_ENV}
echo "query11=${query11}" >> ${DOCK_ENV}
echo "query12=${query12}" >> ${DOCK_ENV}
echo "sam1_f1=${sam1_f1}" >> ${DOCK_ENV}
echo "sam1_f2=${sam1_f2}" >> ${DOCK_ENV}
echo "sam1_f3=${sam1_f3}" >> ${DOCK_ENV}
echo "sam1_f4=${sam1_f4}" >> ${DOCK_ENV}
echo "sam2_f1=${sam2_f1}" >> ${DOCK_ENV}
echo "sam2_f2=${sam2_f2}" >> ${DOCK_ENV}
echo "sam2_f3=${sam2_f3}" >> ${DOCK_ENV}
echo "sam2_f4=${sam2_f4}" >> ${DOCK_ENV}
echo "sam3_f1=${sam3_f1}" >> ${DOCK_ENV}
echo "sam3_f2=${sam3_f2}" >> ${DOCK_ENV}
echo "sam3_f3=${sam3_f3}" >> ${DOCK_ENV}
echo "sam3_f4=${sam3_f4}" >> ${DOCK_ENV}
echo "sam4_f1=${sam4_f1}" >> ${DOCK_ENV}
echo "sam4_f2=${sam4_f2}" >> ${DOCK_ENV}
echo "sam4_f3=${sam4_f3}" >> ${DOCK_ENV}
echo "sam4_f4=${sam4_f4}" >> ${DOCK_ENV}
echo "sam5_f1=${sam5_f1}" >> ${DOCK_ENV}
echo "sam5_f2=${sam5_f2}" >> ${DOCK_ENV}
echo "sam5_f3=${sam5_f3}" >> ${DOCK_ENV}
echo "sam5_f4=${sam5_f4}" >> ${DOCK_ENV}
echo "sam6_f1=${sam6_f1}" >> ${DOCK_ENV}
echo "sam6_f2=${sam6_f2}" >> ${DOCK_ENV}
echo "sam6_f3=${sam6_f3}" >> ${DOCK_ENV}
echo "sam6_f4=${sam6_f4}" >> ${DOCK_ENV}
echo "sam7_f1=${sam7_f1}" >> ${DOCK_ENV}
echo "sam7_f2=${sam7_f2}" >> ${DOCK_ENV}
echo "sam7_f3=${sam7_f3}" >> ${DOCK_ENV}
echo "sam7_f4=${sam7_f4}" >> ${DOCK_ENV}
echo "sam8_f1=${sam8_f1}" >> ${DOCK_ENV}
echo "sam8_f2=${sam8_f2}" >> ${DOCK_ENV}
echo "sam8_f3=${sam8_f3}" >> ${DOCK_ENV}
echo "sam8_f4=${sam8_f4}" >> ${DOCK_ENV}
echo "sam9_f1=${sam9_f1}" >> ${DOCK_ENV}
echo "sam9_f2=${sam9_f2}" >> ${DOCK_ENV}
echo "sam9_f3=${sam9_f3}" >> ${DOCK_ENV}
echo "sam9_f4=${sam9_f4}" >> ${DOCK_ENV}
echo "sam10_f1=${sam10_f1}" >> ${DOCK_ENV}
echo "sam10_f2=${sam10_f2}" >> ${DOCK_ENV}
echo "sam10_f3=${sam10_f3}" >> ${DOCK_ENV}
echo "sam10_f4=${sam10_f4}" >> ${DOCK_ENV}
echo "ref_gtf=${ref_gtf}" >> ${DOCK_ENV}
echo "mask_gtf=${mask_gtf}" >> ${DOCK_ENV}
echo "ref_seq=${ref_seq}" >> ${DOCK_ENV}
# parameters
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "min_isoform_Fraction=${min_isoform_Fraction}" >> ${DOCK_ENV}
echo "labels=${labels}" >> ${DOCK_ENV}
echo "treatAsTimeSeries=${treatAsTimeSeries}" >> ${DOCK_ENV}
echo "species=${species}" >> ${DOCK_ENV}
echo "poissonDispersion=${poissonDispersion}" >> ${DOCK_ENV}
echo "multiReadCorrect=${multiReadCorrect}" >> ${DOCK_ENV}
echo "upperQuartileNorm=${upperQuartileNorm}" >> ${DOCK_ENV}
echo "totalHitsNorm=${totalHitsNorm}" >> ${DOCK_ENV}
echo "compatibleHitsNorm=${compatibleHitsNorm}" >> ${DOCK_ENV}
echo "libraryType=${libraryType}" >> ${DOCK_ENV}
echo "minAlignmentCount=${minAlignmentCount}" >> ${DOCK_ENV}
echo "fdr=${fdr}" >> ${DOCK_ENV}
echo "fragLenMean=${fragLenMean}" >> ${DOCK_ENV}
echo "fragLenStdev=${fragLenStdev}" >> ${DOCK_ENV}
echo "refGTF=${refGTF}" >> ${DOCK_ENV}
echo "skipCuffmerge=${skipCuffmerge}" >> ${DOCK_ENV}
# outputs

echo "THREADS=15" >> ${DOCK_ENV}

#Container exec
DEFAULT_EP="/opt/bin/run-${APPNAME}.sh"
ENTRYPOINT=${ENTRYPOINT:-$DEFAULT_EP}
env | sort -k1 > "_$$.variables"

if [[ "$TYPE" == "docker" ]];
then
	docker run --entrypoint ${ENTRYPOINT} \
	 			--env-file ${DOCK_ENV} \
	 			-v $PWD:/home:rw ${DOCKER_CONTAINER}
fi

if [[ "$TYPE" == "singularity" ]];
then
	
	if [ -f ${SINGULARITY_CONTAINER}.bz2 ];
	then
		bunzip2 ${SINGULARITY_CONTAINER}.bz2

		# Create singularity env
		while read p; do
		  echo "export $p" >> ${SING_ENV}
		done <${DOCK_ENV}
		source ${SING_ENV}

		singularity exec ${SINGULARITY_CONTAINER} ${ENTRYPOINT}
	fi
	
fi

# rm ${DOCK_ENV}*

if [ "${DEBUG}" == "1" ];
then
    set +x
fi