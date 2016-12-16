#!/usr/bin/env bash

APPNAME="fastx"
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"
rm -rf "$DOCK_ENV*"

echo "seq1=${seq1}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "quality_threshold=${quality_threshold}" >> ${DOCK_ENV}
echo "min_length=${min_length}" >> ${DOCK_ENV}
echo "min_quality=${min_quality}" >> ${DOCK_ENV}
echo "percent_bases=${percent_bases}" >> ${DOCK_ENV}
echo "perform_indexing=${perform_indexing}" >> ${DOCK_ENV}

#Container exec
DEFAULT_EP="/opt/bin/run-${APPNAME}.sh"
ENTRYPOINT=${ENTRYPOINT:-$DEFAULT_EP}
env | sort -k1 > "_$$.variables"

if [[ "$TYPE" == "docker" ]];
then
	set -x
	docker run --entrypoint ${ENTRYPOINT} \
	 			--env-file ${DOCK_ENV} \
	 			-v $PWD:/home:rw ${DOCKER_CONTAINER}
	set +x
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

echo "${SINGULARITY_CONTAINER}" >> .agave.archive


# rm ${DOCK_ENV}*