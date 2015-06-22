
# this little script creates a uuid, calculates a checksum and prints them
# out. 

database=database

chksum=`cat "$@" | shasum -a 384 | cut -f1 -d\ `
dir=`echo $chksum | cut -b-2`
file=`echo $chksum | cut -b3-`

if [ ! -f $database/$dir/$file ]; then 
	mkdir -p $database/$dir
	cp "$@" $database/$dir/$file
fi

# if ! grep "$@" catalog; then 
	uuid=`uuidgen -r`
	echo  "$chksum  $uuid "
# fi
