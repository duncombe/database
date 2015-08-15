#! /bin/bash
# this little script creates a uuid, calculates a checksum and prints them
# out. 
# The script is run through find.

catalog=${CATALOG:-catalog}
database=${DATABASE:-database}
srcdir="${SRCDIR:-srcdir}"

# 
# srcfile="${@}"
srcfile="${1}"

# checksum the file
chksum=`cat "$srcfile" | shasum -a 384 | cut -f1 -d\ `

# split the directory and filename to determine where 
# we are going to store it
dir=`echo $chksum |  sed -n 's=^\(..\)\(..\)\(..\).*$=\1/\2/\3=p'`
file=`echo $chksum | cut -b7- `

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
	echo  "$chksum  $uuid  $filepath" >> ${catalog}
else
 	echo \""$srcfile"\" already in database 1>&2
	# echo "$filepath" 1>&2
fi


