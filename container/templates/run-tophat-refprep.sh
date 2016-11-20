# Ported to use Docker image iplantc/dnasub_apps
# Scripts at /opt/scripts/tophat

#----
# Script for creating tar bundle of reference fasta and its index files for tophat/bowtie
# Creates index files
# Bundles everything up
#----

. $PWD/app_begin.sh

ref=${referenceFasta}
cleanup=${cleanupParameter}
echo "Clean up parameter is now set to:"
echo ${cleanup}

# is input compressed? if so, uncompress and update with new filename
ref_ext="${ref##*.}"
if [ ${ref_ext} = "gz" ]; then gunzip ${ref}; ref=${ref%.*}; fi

# standardize extension to .fa
rb="${ref%%.*}"   # reference basename
mv ${ref} ${rb}.fa
ref=${rb}.fa

gzip_output=1
archive_extension="tar"
if [ ${gzip_output} = 1 ]; then compress_flag="z"; archive_extension="tgz"; else compress_flag=""; fi

$DOCKER_APP_RUN samtools faidx ${ref}
$DOCKER_APP_RUN bowtie2-build -q ${ref} ${ref}

$DOCKER_APP_RUN java -Xmx4g -jar /opt/picard-tools-1.120/CreateSequenceDictionary.jar R=${ref} O=${rb}.dict
chmod a+rw ${ref}*
$DOCKER_APP_RUN tar -c${compress_flag}f ${rb}.${archive_extension} ${ref} ${ref}.fai ${rb}.dict ${ref}.1.bt2 ${ref}.2.bt2 ${ref}.3.bt2 ${ref}.4.bt2 ${ref}.rev.1.bt2 ${ref}.rev.2.bt2

if [ ${cleanupParameter} ]; then echo "Cleaning up input and intermediate files"
	rm ${ref}; rm ${ref}.fai; rm ${rb}.dict
	rm -rf *.bt2
else
	echo "Skipping clean up"
fi

. $CWD/app_end.sh

