#! /bin/bash
# find the size of a database: search for the UUID link to the database and
# return the disk usage
# howbig UUID
# ID=6990ec09-0d4c-47aa-9421-8b06b454422c

ID=${1:?}

for f in `locate -0 $ID | xargs -0n1 dirname | grep -v /trash | uniq | grep =$ID$`; do 
	du -sbL --exclude=trash $f
done
