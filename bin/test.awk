
awk --re-interval '
	BEGIN{
		FS="\t"
		# input the index file
		# print ENVIRON[INDEXFILE]
		i=0
		while(getline INDFILE[i] <  ENVIRON["INDEXFILE"]){i++}
		N=i-1
		# write the header and old entries
		J=0 
		
		L=0
		while(INDFILE[J]!~"END OF LIST MARKER"){
			if(L==1){
# dcb969b4-7aa5-4746-8794-3d04144e6652
				mat=match(INDFILE[J],"[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}")
				LIST[substr(INDFILE[J],mat,36)]=INDFILE[J]
				}
			if(INDFILE[J]~"START OF LIST MARKER"){L=1}
			print INDFILE[J++]
			}

		# for(x in LIST){print LIST[x]}

		}

	/^#/{next}
	$4 in LIST{next}
	{ 
		
# 		# from the catalog file: 
# 			# determine if there is a new index entry
# 		for(i=1;i<=J;i++){ print
# 			if(INDFILE[i]~$4){print "starting next"; next}
# 		}
# 			# add the new entry
 		entry= " <li> <a href=\"" $3 "=" $4 "/" $(NF-1) "-DATA\">" $(NF-2) "</a> <a href=\"" $3 "=" $4 "\">" ENVIRON["COLLECTION_TITLE"] "</a></li>"
		LIST[$4]=entry
		print entry
		}
	END{
		# write the rest of the index file
		for(i=J;i<=N;i++){print INDFILE[i]}
	}' $CATALOG

