#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

APPNAME=cuffmerge
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"

rm -rf "$DOCK_ENV*"

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
echo "ref_seq=${ref_seq}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}

echo "THREADS=15" >> ${DOCK_ENV}
echo "DEBUG=${DEBUG}" >> ${DOCK_ENV}

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