
# make_catalog
# register.sh
# create_linked_data

# TODO: test for valid user:group

export CATALOG="/DATA/PUBLICDATA/pub/manifest.txt"
export DATABASE="/DATA/PUBLICDATA/pub/.DATABASE"

./make_catalog "${1:?}"

./create_linked_data /DATA/PUBLICDATA/pub/DATA/ACCESSION/

