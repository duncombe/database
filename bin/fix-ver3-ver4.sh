
export VERSION_CONTROL=numbered

# Set up the database environment
# export ACCESSION_DIR=ACCESSION
# export CATALOG=manifest.txt 
# export DATABASE=.DATABASE
# export INGEST_HOME=/DATA/database/bin

# point to the desired fix-version script
# FIXBIN=/DATA/database/bin/fix-ver2-ver3.sh
# ${FIXBIN} manifest.txt

# throw away the previous links dir 
for F in $ACCESSION_DIR/[0-9][0-9][0-9]*; do 
	mkdir -p $F/trash
	mv $F/?-DATA $F/trash
done

# convert the URL links in ACCESSION/index.html to point to 
# the correct directory
TEMPFILE=$(mktemp)

sed 	-e 's=ACCESSION-UUID/REVISION-DATA=ACCESSION-UUID/DATA/REVISION-DATA='\
	-e 's=\([[:xdigit:]]\{8\}-[[:xdigit:]]\{4\}-[[:xdigit:]]\{4\}-[[:xdigit:]]\{4\}-[[:xdigit:]]\{12\}\)\(/[0-9]\+-DATA\)=\1/DATA\2='\
	${ACCESSION_DIR}/index.html > ${TEMPFILE}

chmod --reference=${ACCESSION_DIR}/index.html ${TEMPFILE}
mv -b ${TEMPFILE} ${ACCESSION_DIR}/index.html

# recreate the linked structure 
$INGEST_HOME/create_linked_data $ACCESSION_DIR

# now tell the log what we did
for FOLDER in $ACCESSION_DIR/[0-9][0-9][0-9]*; do 
	{ echo  $(date) $0 $(cd $INGEST_HOME; git describe --tags) 
	  echo convert $(basename $FOLDER) by shifting data versions n-DATA into DATA folder
	  echo ------------------- 
	} | tee -a $FOLDER/ABOUT/journal.txt >> $LOGFILE
done

# $INGEST_HOME/create_about

