

export VERSION_CONTROL=t

# converts manifest file from n column data to n+1 column data
# adds a parent and AMS acc 

MANIFESTFILE=${1:?}
export AMSACCFILE=${AMSACCFILE:-/DATA/amsaccession}
TEMPFILE=`mktemp`

# AMSACC=`getacc`

# awk -v AMSACC=$AMSACC 
awk 'BEGIN{FS="\t"; OFS="\t"; collid=""}
	/^#/{print} 
	/^# SHASUM/{print "# SHASUM \\t FILEUUID \\t ACCESSION_DATE \\t COLLECTION_UUID \\t PARENT_UUID \\t AMSACC \\t filenamepath "}
	!/^#/{  if (collid != $4){ 
			command="./getacc"
			command | getline AMSACC 
			close(command)
		}
		for(i=1;i<=4;i++){ printf "%s\t",$i}
		# print the parent collection id and the AMS accession number
		printf "%s\t%s",$4,AMSACC
		for(i=5;i<=NF;i++){printf "\t%s",$i}; printf "\n"
		collid=$4
		}
	'  $MANIFESTFILE 

# > $TEMPFILE

# mv -fb $TEMPFILE $MANIFESTFILE

# vi: se tw=0 :

