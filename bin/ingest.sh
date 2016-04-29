#! /bin/bash

# make_catalog
# register.sh
# create_linked_data

# We are changing the format of the WAF.
# It was
# DATA/
#      ACCESSION/
#                {UUID}/
#                       {original-data-folder}/
#
# We want this to become
# DATA/
#      ACCESSION/
#                {UUID}/
#                       ABOUT/
#                       0-DATA/{original-data-folder}/
#                       1-DATA/{modified-data-folder}/
# 
# So we have to make allowance for:
#     1. an additional level of linking
#     2. specifying what version of the data we are writing
#            

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

# test the version of the data we are writing
	i=0
	while [ -e ${ACCESSION_DIR}/${DATAVERSION} ]; do i=$((i+1)); done
	DATAVERSION=${i}-DATA

	${INGEST_HOME}/create_linked_data ${ACCESSION_DIR}/${DATAVERSION}  | tee -a ${LOGFILE}

else
	echo ${LOGFILE} is not writable
	exit 3
fi

