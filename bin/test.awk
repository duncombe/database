
awk '
	BEGIN{
		FS="\t"
		# input the index file
		# print ENVIRON[INDEXFILE]
		i=0
		while(getline INDFILE[i] <  ENVIRON["INDEXFILE"]){i++}
		N=i-1
		# write the header and old entries
		J=0 

		while(INDFILE[J]!~"END OF LIST MARKER"){print INDFILE[J++]}
		}
	/^#/{next}
	{ 
		# from the catalog file: 
			# determine if there is a new index entry
		for(i=1;i<=J;i++){ print
			if(INDFILE[i]~$4){print "starting next"; next}
		}
			# add the new entry
		print " <li> <a href=\"" $3 "=" $4 "/" $(NF-1) "-DATA\">" $(NF-2) "</a> <a href=\"" $3 "=" $4 "\">" ENVIRON["COLLECTION_TITLE"] "</a></li>"
		}
	END{
		# write the rest of the index file
		for(i=J;i<=N;i++){print INDFILE[i]}
	}' $CATALOG

