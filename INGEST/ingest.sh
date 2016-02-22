#! /bin/bash

# make_catalog
# register.sh
# create_linked_data

# TODO: test for valid user:group

# set the base directory for the ingest code
INGEST_HOME=${INGEST_HOME:?Set environment variable INGEST_HOME}

export CATALOG=${CATALOG:-"/DATA/PUBLICDATA/pub/manifest.txt"}
export DATABASE=${DATABASE:-"/DATA/PUBLICDATA/pub/.DATABASE"}
export LOGFILE=${LOGFILE:-"/DATA/PUBLICDATA/pub/ingest.log"}
export ACCESSION_DIR=${ACCESSION_DIR:-"/DATA/PUBLICDATA/pub/DATA/ACCESSION/"}
export SOURCE_DIR="${1:?}"

[ -d "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not accessible ; exit 1 ; } 
[ -x "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not searchable ; exit 2 ; } 

[ -e ${LOGFILE} ] || touch ${LOGFILE}

if [ -w ${LOGFILE} ] ; then 


	${INGEST_HOME}/make_catalog "${SOURCE_DIR}" | tee -a ${LOGFILE}

	${INGEST_HOME}/create_linked_data ${ACCESSION_DIR}  | tee -a ${LOGFILE}

else
	echo ${LOGFILE} is not writable
	exit 3
fi

