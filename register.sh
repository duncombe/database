#! /bin/bash
# this little script creates a uuid, calculates a checksum and prints them
# out. 

catalog=${CATALOG:-catalog}
database=${DATABASE:-database}

chksum=`cat "$@" | shasum -a 384 | cut -f1 -d\ `
dir=`echo $chksum | cut -b-2`
file=`echo $chksum | cut -b3-`

if [ ! -f $database/$dir/$file ]; then 
	mkdir -p $database/$dir
	cp -i "$@" $database/$dir/$file
 	echo Copying in $file 1>&2
fi

if [ ! -f $catalog ]; then
	touch $catalog
# 	echo Forced to create $catalog 1>&2
fi

if ( ! grep "$@" $catalog > /dev/null ) ; then 
	uuid=`uuidgen -r`
	echo  "$chksum  $uuid "
# else
# 	echo \"$@\" already in database 1>&2
fi
