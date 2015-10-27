
# Instructions

## Shell script version

0. Create metadata file for the collection. 
1. Run ingest.sh    
    ingest.sh <data_directory> calls     
    1. sets up database environment variables
    2. calls make_catalog 
    3. create_linked_data

These scripts  add the contents of the data directorry to the manifest,
distribute the files into the database, link the WAF to the files. 


## Python script version

Shell script has still to be converted to Python. 



