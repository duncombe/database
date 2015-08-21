
for a filename     

-	calculate a shasum  
-	check if the shasum is in the database  
-	if not create the database entry  
-	calculate a uuid  
-	print the shasum, the uuid, and the original filename   

Miscellaneous notes:  
- http://zetcode.com/db/mysqlpython/ for working with MySQL in Python

for a file
- calculate a checksum
- check if the checksum is in the database 
- if not 
    - calculate a uuid 
    - update the catalog
    - copy the file into the WAF 
         - cut the first byte, 
              - if there are directories, cut the next byte, and copy the file into the appropriate WAF 
              - if there are no directories copy the file into the directory
              - if there are more than 256 entries in the directory, distribute entries into subdirectories






