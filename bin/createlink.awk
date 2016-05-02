#! /usr/bin/gawk  -f
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
	accpath=acc "/" $(NF-1) "-DATA" "/" path
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
