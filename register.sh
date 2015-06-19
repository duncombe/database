
# this little script creates a uuid, calculates a checksum and prints them
# out. 

chksum=`cat "$@" | shasum -a 384 | cut -f1 -d\ `
dir=`echo $chksum | cut -b-2`
file=`echo $chksum | cut -b3-`

if [ -f $dir/$file ]; then 
	echo \"$@\" already registered
else
	mkdir database/$dir
	cp -i "$@" $dir/$file

	uuid=`uuidgen -r`
	echo $chksum  $uuid  $@ >> catalog
fi
