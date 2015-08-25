#! /bin/bash

TMPFILE=`mktemp`
SAVDIR=/tmp/large

mkdir -p $SAVDIR
i=0
N=$(($RANDOM/10))

echo Creating $N files

while [ $i -lt $N  ] ; do
	dd < /dev/urandom > $TMPFILE count=$RANDOM bs=1  2> /dev/null
	SAVFILE=`shasum -a384 $TMPFILE| cut -f1 -d\ `
	if [ -e $SAVDIR/$SAVFILE ] ; then 
		echo File already exists
		ls -ld $SAVDIR/$SAVFILE
	else
		cat $TMPFILE > $SAVDIR/$SAVFILE
	fi
	i=$((i+1))
done

rm $TMPFILE

