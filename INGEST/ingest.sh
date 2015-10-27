
# make_catalog
# register.sh
# create_linked_data

# TODO: test for valid user:group

export CATALOG="/DATA/PUBLICDATA/pub/manifest.txt"
export DATABASE="/DATA/PUBLICDATA/pub/.DATABASE"
export LOGFILE="/DATA/PUBLICDATA/pub/ingest.log"
export ACCESSION_DIR="/DATA/PUBLICDATA/pub/DATA/ACCESSION/"

./make_catalog "${1:?}" | tee -a ${LOGFILE}

./create_linked_data ${ACCESSION_DIR}  | tee -a ${LOGFILE}

