#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

APPNAME=cufflinks
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"

rm -rf "$DOCK_ENV*"

echo "query1=${query1}" >> ${DOCK_ENV}
echo "MASK_GTF=${MASK_GTF}" >> ${DOCK_ENV}
echo "BIAS_FASTA=${BIAS_FASTA}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "libraryType=${libraryType}" >> ${DOCK_ENV}
echo "label=${label}" >> ${DOCK_ENV}
echo "annotation=${annotation}" >> ${DOCK_ENV}
echo "gtf=${gtf}" >> ${DOCK_ENV}
echo "guide_gtf=${guide_gtf}" >> ${DOCK_ENV}
echo "multiReadCorrect=${multiReadCorrect}" >> ${DOCK_ENV}
echo "upperQuartileNorm=${upperQuartileNorm}" >> ${DOCK_ENV}
echo "totalHitsNorm=${totalHitsNorm}" >> ${DOCK_ENV}
echo "compatibleHitsNorm=${compatibleHitsNorm}" >> ${DOCK_ENV}
echo "minIsoformFraction=${minIsoformFraction}" >> ${DOCK_ENV}
echo "preMrnaFraction=${preMrnaFraction}" >> ${DOCK_ENV}
echo "maxIntronLength=${maxIntronLength}" >> ${DOCK_ENV}
echo "smallAnchorFraction=${smallAnchorFraction}" >> ${DOCK_ENV}
echo "overhangTolerance=${overhangTolerance}" >> ${DOCK_ENV}
echo "maxBundleLength=${maxBundleLength}" >> ${DOCK_ENV}
echo "minIntronLength=${minIntronLength}" >> ${DOCK_ENV}
echo "trim3avgcovThresh=${trim3avgcovThresh}" >> ${DOCK_ENV}
echo "trim3dropoffFrac=${trim3dropoffFrac}" >> ${DOCK_ENV}
echo "minFragsPerTransfrag=${minFragsPerTransfrag}" >> ${DOCK_ENV}
echo "intronOverhangTolerance=${intronOverhangTolerance}" >> ${DOCK_ENV}
echo "overhangTolerance3=${overhangTolerance3}" >> ${DOCK_ENV}
echo "noFauxReads=${noFauxReads}" >> ${DOCK_ENV}

echo "DEBUG=${DEBUG}" >> ${DOCK_ENV}
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

		echo "${SINGULARITY_CONTAINER}" >> .agave.archive

		singularity exec ${SINGULARITY_CONTAINER} ${ENTRYPOINT}
	fi
	
fi

# rm ${DOCK_ENV}*

if [ "${DEBUG}" == "1" ];
then
    set +x
fi