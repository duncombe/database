#! /bin/bash

# make_catalog
# register.sh
# create_linked_data

# It is sdafer to call this script from another script which tests the
# environment variables fully. The script you should use should be based on
# acquire_template which is in the $INGEST_HOME 

if [ `ps -o stat= -p $PPID` = "Ss" ]; then 
	read -p "It is wiser to use the acquire wrapper to run $0. Continue? (y/N) " ans
	ans=${ans^^}
	[ "${ans:0:1}" = "Y" ] || exit 1
fi

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
# We do this by checking if certain files are writeable

# If the lockfile does not exist, bomb out immediately
LOCKFILE=${LOCKFILE:-/var/lock/amsaccession.lock}
if [ ! -e $LOCKFILE ]; then 
	echo The lock file is not accessible
	exit 12
fi

# set the base directory for the ingest code
INGEST_HOME=${INGEST_HOME:?Set environment variable INGEST_HOME}

export CATALOG=${CATALOG:-"/DATA/PUBLICDATA/pub/manifest.txt"}
export DATABASE=${DATABASE:-"/DATA/PUBLICDATA/pub/.DATABASE"}
export LOGFILE=${LOGFILE:-"/DATA/PUBLICDATA/pub/ingest.log"}
export ACCESSION_DIR=${ACCESSION_DIR:-"/DATA/PUBLICDATA/pub/DATA/ACCESSION/"}
export SOURCE_DIR="${1:?}"
# Assume this is the original data submission if there is none specified
export REVISION=${REVISION:-0}
export COLLECTION_TITLE=${COLLECTION_TITLE:?Provide a title for collection (COLLECTION_TITLE)}
export COLLECTION=${COLLECTION}

[ -d "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not accessible ; exit 1 ; } 
[ -x "${SOURCE_DIR}" ] || { echo ${SOURCE_DIR} is not searchable ; exit 2 ; } 

# test permissions 
function alterable(){
	if [ -e ${1} ] ; then 
		[ -w ${1} ] || { echo ${1} is not writable;  false ; return; }
	else
		[ -w $(dirname ${1}) ] || { echo $(dirname ${1}) is not writable;  false; return; }
	fi
	true
}

[ -e ${LOGFILE} ] || touch ${LOGFILE} 
[ -w ${LOGFILE} ] || { echo ${LOGFILE} is not writable;  exit 3 ; }
alterable ${CATALOG} || exit 4
alterable ${DATABASE} || exit 5

set -o pipefail
${INGEST_HOME}/make_catalog "${SOURCE_DIR}" | tee -a ${LOGFILE}
set +o pipefail

echo Made catalog 

echo Creating linked data \(may take a while\) ...

{ ${INGEST_HOME}/create_linked_data ${ACCESSION_DIR} || exit 6 ; } | tee -a ${LOGFILE}

echo Created linked data

${INGEST_HOME}/create_about

echo Created ABOUT

echo Done.

# vi: se nowrap tw=0 :

