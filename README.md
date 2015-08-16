# Database

A test suite for loading data into a simple database. Work flow is anticipated to be as follows:

1. A data collection is acquired consisting of files arranged in a directory structure. Files may be of any type. Metadata in XML or JSON files may or may not be present.
1. The collection is stored as a folder with sub-folders. 
1. The top-level folder is assigned a UUID and Accession Number. 
1. The UUID and collection metadata are stored in a collection table in a relational database. 
1. The directory structure is read. 
1. For each file in the collection,  the `SHASUM -a384`  is calculated and the file copied to 
a second database structure such that the path name of each file 
can be reduced to the 
SHASUM, e.g., a file with shasum of 
38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
will be stored as
`${DATABASE}/38/b0/60/a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b`. 
1. A UUID is assigned to each file in the second database and added to a files table in the MySQL database. 
    1. The files table has the collection ID, the shasum, the file UUID, the original filename and path, and the name of an XML file that holds the metadata for that file. 


