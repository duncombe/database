SAVED=0
EXISTS=0
SPLITDIR=/tmp/small1

SPLITDIR=${SPLITDIR%/}/

[ ! -e $SPLITDIR ] && mkdir -p $SPLITDIR

# sed 's=^\(..\)\(..\)\(..\)=\1/\2/\3/=' `
# sed 's=^\(..\)\(..\)=\1/\2/=' `

for f in $@ ; do
	SAVEPATH=${SPLITDIR}`echo $(basename $f) |
		sed 's=^\(..\)=\1/=' `
	if [ ! -e $SAVEPATH ]; then
		mkdir -p $(dirname $SAVEPATH)
		cp -i $f $SAVEPATH
		SAVED=$((SAVED+1))
	else
		EXISTS=$((EXISTS+1))
	fi
done
echo $SAVED saved 
echo $EXISTS already exist

