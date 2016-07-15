#! /bin/bash

# this is for GNU coreutils -  backup type when copying a file
export VERSION_CONTROL=numbered 

# converts manifest file from n column data to n+1 column data
# adding a revision number

MANIFESTFILE=${1:?}

# check that this is a valid file to work on 
if [ $(grep "^#.*SHASUM" ${MANIFESTFILE} | awk 'END{print NF}') -ge 16 ]; then
	echo $MANIFESTFILE has already been processed. Cannot reprocess.
	exit 1
fi

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export SCRIPTVERSION=$(tail -n1 $BINDIR/version)

TEMPFILE=`mktemp`

# GETACCSCRIPT=`mktemp`
# cat << ENDIN > $GETACCSCRIPT
# #! /bin/bash
# AMSACCFILE=${AMSACCFILE:-/DATA/amsaccession}
# if [ ! -e $AMSACCFILE ]; then
# 	touch $AMSACCFILE
# fi 
# TMPFILE=$(mktemp)
#        ( flock 9
#          echo $(($(cat $AMSACCFILE)+1)) > $TMPFILE
#          cat $TMPFILE > $AMSACCFILE
#        ) 9< /var/lock/amsaccession.lock
#        cat $TMPFILE 
#        rm -f ${TMPFILE}
# ENDIN 

# AMSACC=`getacc`

awk -v BINDIR=$BINDIR	\
	'BEGIN{FS="\t"; OFS="\t"; collid=""}
	/^#/{print}
	/^# SHASUM/{
		print "# catalog file converted to database script version: " ENVIRON["SCRIPTVERSION"]
		print "# conversion script run by " ENVIRON["USER"] "@" ENVIRON["HOSTNAME"] " at " strftime()
		print "# SHASUM \\t FILEUUID \\t ACCESSION_DATE \\t COLLECTION_UUID \\t PARENT_UUID \\t AMSACC \\t REVISION \\t filenamepath "}
	!/^#/{  
		for(i=1;i<=(NF-1);i++){ printf "%s\t",$i}
		# print the revision number 
		printf "0\t%s",$NF; printf "\n"
		}
	'  $MANIFESTFILE > $TEMPFILE

mv -fb $TEMPFILE $MANIFESTFILE

# vi: se tw=0 :

