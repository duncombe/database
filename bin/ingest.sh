#! /bin/bash

# if false; then 

# make_catalog
# register.sh
# create_linked_data

# It is safer to call this script from another script which tests the
# environment variables fully. The script you should use should be based on
# acquire_template which is in the $INGEST_HOME 

if [ `ps -o stat= -p $PPID` = "Ss" ]; then 
	read -p "It is wiser to use the acquire wrapper to run $0. Continue? (y/N) " ans
	ans=${ans^^}
	[ "${ans:0:1}" = "Y" ] || exit 9
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

export HTACCESS=${HTACCESS:-false}
export CATALOG=${CATALOG:-"/DATA/PUBLICDATA/pub/manifest.txt"}
export DATABASE=${DATABASE:-"/DATA/PUBLICDATA/pub/.DATABASE"}
export LOGFILE=${LOGFILE:-"/DATA/PUBLICDATA/pub/ingest.log"}
export ACCESSION_DIR=${ACCESSION_DIR:-"/DATA/PUBLICDATA/pub/DATA/ACCESSION/"}
export SOURCE_DIR="${1:?}"
# Assume this is the original data submission if there is none specified
export REVISION=${REVISION:-0}
export COLLECTION_TITLE=${COLLECTION_TITLE:?Provide a title for collection (COLLECTION_TITLE)}

# COLLECTION is a pre-issued accession UUID for the dataset. If COLLECTION is
# empty, a new accession will be generated by make_catalog
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

# information is generated in make_catalog, create_linked_data, create_about
# and friends, that we would like to have access to in the higher levels
# scripts like this one. Create a temporary file here, export the name, and
# write to it in the called scripts. Read back information when we need it. 

export ENVIRONMENT_FILE=`mktemp` 

set -o pipefail
${INGEST_HOME}/make_catalog "${SOURCE_DIR}" | tee -a ${LOGFILE}
set +o pipefail

echo Made catalog 

echo Creating linked data \(may take a while\) ...

# retrieve the accession date (ACCESSION_DATE) and the uuid (COLLECTION) from
# the ENVIRONMENT_FILE

ACCESSION_DATE=${ACCESSION_DATE:-`grep "^ACCESSION_DATE\>" $ENVIRONMENT_FILE |
	awk '{print $3}'`}
COLLECTION=${COLLECTION:-`grep "^COLLECTION\>" $ENVIRONMENT_FILE |
	awk '{print $3}'`}

REGEX="$ACCESSION_DATE	$COLLECTION"

{ ${INGEST_HOME}/create_linked_data ${ACCESSION_DIR} "${REGEX}" || exit 6 ; } |
	tee -a ${LOGFILE}

echo Created linked data

${INGEST_HOME}/create_about

# fi 

echo Created ABOUT

# retrieve a bunch of variables
COLLECTION_DIR=$(grep COLLECTION_DIR ${ENVIRONMENT_FILE} | sed 's/^.*COLLECTION_DIR *= //')
ACCESSION_DIR=$(grep ACCESSION_DIR ${ENVIRONMENT_FILE} | sed 's/^.*ACCESSION_DIR *= //')
AMSACC=$(grep "^AMSACC\>" ${ENVIRONMENT_FILE} | sed 's/^.*AMSACC *= //')
MIMSACC=$(basename ${COLLECTION_DIR})

# provide some privacy. users will ask to have this lifted, by default put it
# in. This code should be moved earlier, to when the accession directory is
# created. 
if [ ! -e ${COLLECTION_DIR}/.htaccess ]; then 
	    if $HTACCESS ; then 
		cat <<-ENDIN > ${COLLECTION_DIR}/.htaccess
			AuthType Basic
			AuthName "Restricted Content: to access these data contact data@ocean.gov.za"
			AuthUserFile /etc/httpd/htpasswd
			Require valid-user
		ENDIN
		echo  .htaccess file written in ${COLLECTION_DIR}
	    fi
fi

# make an easy link to the accession dir 
ln -s $(basename ${COLLECTION_DIR}) $ACCESSION_DIR/$AMSACC 

# keep a copy of the variables used with the accession (remember we wrote it in the source directory)
if [ -e ${ENVIRONMENT_FILE} ]; then 
	cat ${ENVIRONMENT_FILE} >> ${COLLECTION_DIR}/ABOUT/accessioned_as.txt
	rm ${ENVIRONMENT_FILE}
fi 

# We've been keeping a git repo of accession dirs. The repo has somehow missed
# being accessioned.  Test if a repo exists, then warn.

( cd ${ACCESSION_DIR}
  if [ ! -z "$(git status --porcelain)" ]; then 
    # Uncommitted changes
    echo $ACCESSION_DIR is unclean. The git repo needs to be updated. 
    read -p "Do it (y) or leave it (N)? " ANS
    ANS=${ANS^^}
    [ "${ANS:0:1}" = "Y" ] && { 
	git add index.html $AMSACC $MIMSACC 
	git commit -m "Accessioned $AMSACC" | head -n2
	} 
  fi
)

echo Done.

# vi: se nowrap tw=0 :

