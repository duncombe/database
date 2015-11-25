
# make_catalog
# register.sh
# create_linked_data

# TODO: test for valid user:group

export CATALOG="/DATA/PUBLICDATA/pub/manifest.txt"
export DATABASE="/DATA/PUBLICDATA/pub/.DATABASE"
export LOGFILE="/DATA/PUBLICDATA/pub/ingest.log"
export ACCESSION_DIR="/DATA/PUBLICDATA/pub/DATA/ACCESSION/"
export SOURCE_DIR="${1:?}"

[ -d "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not accessible ; exit 1 ; } 
[ -x "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not searchable ; exit 2 ; } 

[ -e ${LOGFILE} ] || touch ${LOGFILE}

if [ -w ${LOGFILE} ] ; then 


	./make_catalog "${SOURCE_DIR}" | tee -a ${LOGFILE}

	./create_linked_data ${ACCESSION_DIR}  | tee -a ${LOGFILE}

else
	echo ${LOGFILE} is not writable
	exit 3
fi

