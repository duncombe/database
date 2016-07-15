#! /bin/bash

# this is for GNU coreutils -  backup type when copying a file
export VERSION_CONTROL=numbered 

# converts manifest file from n column data to n+2 column data
# adding a parent accession number and an AMS accession number 

# export AMSACCFILE=${AMSACCFILE:-/DATA/amsaccession}
export AMSACCFILE=${AMSACCFILE:?AMSACCFILE is not set. Set environment variables before running $0}

MANIFESTFILE=${1:?}

# check that this is a valid file to work on 
if [ $(grep "^#.*SHASUM" ${MANIFESTFILE} | awk 'END{print NF}') -ge 14 ]; then
	echo $MANIFESTFILE has already been processed. Cannot reprocess.
	exit 1
fi

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
	/^# SHASUM/{print "# SHASUM \\t FILEUUID \\t ACCESSION_DATE \\t COLLECTION_UUID \\t PARENT_UUID \\t AMSACC \\t filenamepath "}
	!/^#/{  if (collid != $4){ 
			command=BINDIR "/getacc"
			command | getline AMSACC 
			close(command)
		}
		for(i=1;i<=4;i++){ printf "%s\t",$i}
		# print the parent collection id and the AMS accession number
		printf "%s\t%s",$4,AMSACC
		for(i=5;i<=NF;i++){printf "\t%s",$i}; printf "\n"
		collid=$4
		}
	'  $MANIFESTFILE > $TEMPFILE

mv -fb $TEMPFILE $MANIFESTFILE

# vi: se tw=0 :

