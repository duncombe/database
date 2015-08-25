SAVED=0
EXISTS=0
for f in $@ ; do
	SAVEPATH=/tmp/small/`echo $(basename $f) | sed 's=^\(..\)\(..\)\(..\)=\1/\2/\3/=' `
	if [ ! -e $SAVEPATH ]; then
		mkdir -p $(dirname $SAVEPATH)
		cp -i $f $SAVEPATH
		SAVED=$((SAVED+1))
	else
		EXISTS=$((EXISTS+1))
	fi
done
echo $SAVED saved 
echo $EXISTS already exists 

