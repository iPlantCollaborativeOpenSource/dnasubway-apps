#!/usr/bin/env bash

set -x

APPNAME=tophat
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"

rm -rf "$DOCK_ENV*"

echo "query1=${query1}" >> ${DOCK_ENV}
echo "query2=${query2}" >> ${DOCK_ENV}
echo "genome=${genome}" >> ${DOCK_ENV}
echo "gtf=${annotation}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "output_dir=tophat_out" >> ${DOCK_ENV}
echo "mate_inner_dist=${mate_inner_dist}" >> ${DOCK_ENV}
echo "mate_std_dev=${mate_std_dev}" >> ${DOCK_ENV}
echo "min_anchor_length=${min_anchor_length}" >> ${DOCK_ENV}
echo "splice_mismatches=${splice_mismatches}" >> ${DOCK_ENV}
echo "min_intron_length=${min_intron_length}" >> ${DOCK_ENV}
echo "max_intron_length=${max_intron_length}" >> ${DOCK_ENV}
echo "max_insertion_length=${max_insertion_length}" >> ${DOCK_ENV}
echo "max_deletion_length=${max_deletion_length}" >> ${DOCK_ENV}
echo "min_isoform_fraction=${min_isoform_fraction}" >> ${DOCK_ENV}
echo "max_multihits=${max_multihits}" >> ${DOCK_ENV}
echo "segment_length=${segment_length}" >> ${DOCK_ENV}
echo "library_type=${library_type}" >> ${DOCK_ENV}
echo "read_mismatches=${read_mismatches}" >> ${DOCK_ENV}
echo "no_novel_junc=${no_novel_juncs}" >> ${DOCK_ENV}
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

set +x