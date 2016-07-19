#! /usr/bin/gawk  -f
# 
# The format of the WAF is changing.
# 
# It was
# DATA/
#      ACCESSION/
#                {UUID}/
#                       {original-data-folder}/
#
# We want it to become
# DATA/
#      ACCESSION/
#                {UUID}/
#                       ABOUT/
#                       0-DATA/{original-data-folder}/
#                       1-DATA/{modified-data-folder}/
# 
# So we have to make allowance for:
#     1. an additional level of linking
#     2. specifying what version of the data we are writing
#            
BEGIN{  FS="\t"
        SD=ENVIRON["LINKDIR"] 
        RRD=ENVIRON["LINKPATH"]
	}
/^#/{next}
{
	# reset the relative directory counter
	RD=RRD
	# work out where the file is found in the database
	dbdir=substr($1,1,2)
	dbfile=substr($1,3)
	# get the filename and path we want to place
	rawfile=$NF 
	cmd="basename \"" rawfile "\""
	cmd | getline file ;  close(cmd) 
	cmd="dirname \"" rawfile "\""
	cmd | getline path ;  close(cmd) 
	# work out the accession number
	acc=$3 "=" $4 
	# accpath=acc "/" $(NF-1) "-DATA" "/" path
	accpath=acc "/DATA/" $(NF-1) "-DATA" "/" path
	cmd2="test -d \"" SD "/" accpath "\""
	if (system(cmd2)==1){
		cmd="mkdir -pv \"" SD "/" accpath "\""
		system(cmd) ; close(cmd)
		}
	close(cmd2)
	# work out the link
	N=split(accpath,a,"/")+1
	for (i=1;i<N;i++){RD="../" RD}
	if (length(dbfile)!=0 && length(rawfile)!=0){
		isnotalink="test -L \"" SD "/" accpath "/" rawfile "\""
		if (system(isnotalink)){
			cmd="ln -sf \"" RD "/" dbdir "/" dbfile "\" \"" SD "/" accpath "/" file "\""
			system(cmd) ; close(cmd)
			}
		close(isnotalink)
		}
	else{
		print "Bad catalog entry: " FNR " (" NR ")" > "/dev/stderr"
	}
}

# vi: se tw=0 nowrap :
