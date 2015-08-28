#! /bin/bash
# 
# this little script
# 	gets a uuid
# 	calculates a checksum 
# 	prints them out. 
# 
# The script is expecting to be called from this find command:
#    find ${SRCDIR} -type f -exec bash $(pwd)/register.sh \{\} \;
# 

# ensure we have set all these environment variables in the calling script
accession=${ACCESSION:?}
collection=${COLLECTION:?}
catalog=${CATALOG:?}
database=${DATABASE:?}
srcdir="${SRCDIR:?}"

if [ ! -d ${database} ]; then 
	mkdir -p $database
fi

# ensure that database has no trailing /
database="${database%/}"

MANIFESTFORM="# SHASUM \t FILEUUID \t ACCESSION_DATE \t COLLECTION_UUID \t filenamepath "

if [ ! -f ${catalog} ]; then 
	{
	echo "# Test database catalog"
	# output to catalog is 
	echo "${MANIFESTFORM}"
	} > $catalog
fi

# 
# srcfile="${@}"
srcfile="${1}"

# checksum the file
chksum=`cat "$srcfile" | shasum -a 384 | cut -f1 -d\ `

# split the directory and filename to determine where 
# we are going to store it
# dir=`echo $chksum |  sed -n 's=^\(..\)\(..\)\(..\).*$=\1/\2/\3=p'`
# file=`echo $chksum | cut -b7- `
dir=`echo $chksum |  sed -n 's=^\(..\).*$=\1=p'`
file=`echo $chksum | cut -b3- `

# Make a note of the original filepath 
filepath=`echo "${srcfile#$srcdir}"`

# check if the file exists in the database
# if not, copy it in
if [ ! -f $database/$dir/$file ]; then 
	mkdir -p $database/$dir
	cp -i "$@" $database/$dir/$file
 	echo Copying in "$srcfile" 1>&2
fi

# Test if the catalog exists, 
if [ ! -f $catalog ]; then
	touch $catalog
 	echo Forced to create $catalog 1>&2
fi

# check if the filepath is already in the catalog. If not create a UUID and 
# add the details to the catalog
if ( ! grep -v "^#" $catalog | grep "$filepath" > /dev/null ) ; then 
	uuid=`uuidgen -r`
## THIS LINE MUST CORRESPOND WITH THE COMMENT WHEN THE DATABASE WAS CREATED
## MANIFESTFORM
	echo -e "${chksum}\t${uuid}\t${accession}\t${collection}\t${filepath}" >> ${catalog}
else
 	echo \""$srcfile"\" already in database 1>&2
	# echo "$filepath" 1>&2
fi


