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
amsacc=${AMSACC:?}
parent=${PARENT:?}
accession_date=${ACCESSION_DATE:?}
collection=${COLLECTION:?}
catalog=${CATALOG:?}
database=${DATABASE:?}
srcdir="${SRCDIR:?}"
revision="${REVISION:?}"

if [ ! -d ${database} ]; then 
	mkdir -p $database
fi

# ensure that database has no trailing /
database="${database%/}"

##
## THE FOLLOWING LINE MUST CORRESPOND WITH THE OUTPUT WHEN THE DATABASE IS WRITTEN
## MANIFESTFORM
## 
# REVISION must be the entry before the filenamepath
MANIFESTFORM="# SHASUM \t FILEUUID \t ACCESSION_DATE \t COLLECTION_UUID \t PARENT_UUID \t AMSACC \t REVISION \t filenamepath "

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
# dir=`echo $chksum |  sed -n 's=^\(..\).*$=\1=p'`
# dir=`echo $chksum |  cut -b-2 `
# file=`echo $chksum | cut -b3- `
dir=${chksum:0:2}
file=${chksum:2}

# Make a note of the original filepath 

filepath=`echo $(basename "$srcdir")/"${srcfile#$srcdir}"`

# check if the file exists in the database
# if not, copy it in
if [ ! -f $database/$dir/$file ]; then 
	mkdir -pv $database/$dir
	cp -iv "$@" $database/$dir/$file
 	echo Copying in "$srcfile" 1>&2
else
 	echo "$srcfile" already exists as $dir/$file
fi

# Test if the catalog exists, 
if [ ! -f $catalog ]; then
	touch $catalog
 	echo Forced to create $catalog 
 	echo Forced to create $catalog 1>&2
fi

# check if the filepath is already in the catalog. If not create a UUID and 
# add the details to the catalog
uuid=$(grep -v "^#" ${catalog} | grep "${filepath}" | grep "${collection}" | cut -sf2 -d"	" )
if [ -z "$uuid" ] ; then 
	uuid=`uuidgen -r`
else
 	echo \""$srcfile"\" already in database 1>&2
	# echo "$filepath" 1>&2
fi
##
## THE FOLLOWING LINE MUST CORRESPOND WITH THE COMMENT WHEN THE DATABASE WAS CREATED
## see variable MANIFESTFORM
##
# revision must be the entry before filenamepath
echo -e "${chksum}\t${uuid}\t${accession_date}\t${collection}\t${parent}\t${amsacc}\t$revision\t${filepath}" >> ${catalog}

# vim: se nowrap tw=0 :

