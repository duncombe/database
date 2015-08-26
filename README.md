# database

A test suite for creating an accession in a simple database.  Includes
rudimentary tools to assign UUIDs, calculate SHA checksums and add files to the
database (from a set of web-accessible folders (WAFs)).  This initial pass at
the problem is intended to create an emergency database that can easily be
incorporated into a more mature product as one becomes available.

## Workflow

Ingest flow is anticipated to be as follows:

1. A data collection is acquired consisting of files arranged in some provider defined directory structure. Files may be of any type.
Metadata in XML or JSON files may or may not be present.  
In ISO-14721 terminology, this suite is termed a Submission Information Package (SIP).
2. The SIP is assigned an accession number.
   1. The accession number is proposed to be of the form YYYYMMDD:UUID, with the first eight digits indicating the date that the dataset was ingested 
into the system, and the next following digits, a universally unique identifier. 
1. The UUID (accession number) and accession-level metadata are stored in an accession information table, ultimately in a SQL database,
initially in a TSV manifest. For the sake of redundancy and guarding against database corruption, the TSV manifest will be maintained. 
1. The SIP directory structure is read. 
1. Each subdirectory is also assigned a UUID, since each may represent a (related) dataset, e.g., `CRUISE1/CTD`, `CRUISE1/ADCP`.
1. For each file in the SIP,  the 384-bit Secure Hash Algorithm checksum, `shasum -a 384`,  is calculated and 
the file inserted into a sdatabase structure, `${DATABASE}/` such that the path name of each file can be reduced to the SHASUM, 
e.g., a file with SHASUM-384 of 
`38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b`
would be stored as   
`${DATABASE}/38/b0/60/a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b`. 
1. The SHASUMs and original pathnames are recorded in the manifest as children of the accession ID.
1. The TSV manifest is committed to a git repository.
    1. The manifest table has the parent accession ID, the sub-directory UUID, the file SHASUM, the original filename and path.  
    1. Where is the metadata for the SIP? There should be 
	Producer Title Abstract Date Time UUID Accession Fileslist, etc. 
1. Publication database is constructed by making symlinks to `$DATABASE`.
1. Metadata database includes x-links to `$DATABASE`. 



```
DATA/
|- INGEST/
|  |- YYYYMMDD-UUID/
|  |  |- My special data set/
|  |     |- Bunch of directories with stupid names/
|  |     |- More stupidly named directories/
|  |        |- Worse - named-file'_s with bad! punctuation & spelling
|  |        |- A file with data in 
|  |        |- A file with no data in
|  |  
|  |- yyyymmdd-uuid/
|  |  |- Cruise 321/
|  |     |- CTD/
|  |     |- XBT/
|  |     |- Chlorophyll/
|  |        |- chladata.dat
|  |        |- chladata.xls
|  | 
|  |- 20150825-3f9b441f-1e05-48e8-9d73-90dbd9123a0a
|  
|- ARCHIVE               # permanent record of raw SIP data
|  |- YYYYMMDD-UUID.tar
|  |- yyyymmdd-uuid.tar
|  |- 20150825-3f9b441f-1e05-48e8-9d73-90dbd9123a0a.tar
.  .
.  .
.  .
| 
|- DATABASE/
|  |- 00/
|  |  |- 0001f0128adfea073e ... 12ff # shasum named file -
|  |                                 # this file has SHASUM-384 of
|  |                                 # 000001f0128adfea073e...12ff
|  |- 01/ 
.  .  .      
.  .  .      
.  .  .      
|  |- 38/
|  |  |- b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
|  |- 39/
|  |- 3a/
|  .
|  .
|  .`
|  |- fe/
|  |- ff/ 
|
|- PUBLICDATA           # folder presented to clients; links from here point to the SHASUM database
|  |- YYYYMMDD-UUID/
|  |  |- My special data set/
|  |     |- Bunch of directories with stupid names/
|  |     |- More stupidly named directories/
|  |        |- Worse - named-file'_s with bad! punctuation & spelling -> DATA/DATABASE/00/0001f0128...12ff
|  |        |- A file with data in -> DATA/DATABASE/6e/315526e9ec5d349196538bf01b00ec6d740d045cbd66...5771
|  |        |- A file with no data in -> DATA/DATABASE/38/b060a751ac96384cd9327eb1b1e36a21fdb71114b...b95b
|  |  
|  |- yyyymmdd-uuid/
|  |  |- Cruise 321/
|  |     |- CTD/
|  |     |- XBT/
|  |     |- Chlorophyll/
|  |        |- chladata.dat -> DATA/DATABASE/2d/91bec7158d942b3c7ed26a0b627f55d00ee8e0c0921283884d07...10a6
|  |        |- chladata.xls -> DATA/DATABASE/13/20013e3d0ad7728eb4cad4e6612fbada62761530b5387cbaf322...4686
|  |
|  |- 20150825-3f9b441f-1e05-48e8-9d73-90dbd9123a0a
.
.
.
|- UUIDLINKS/      # Each subdirectory (dataset) was assigned a UUID. These links point back to the directory in PUBLICDATA
|  |- 8584e980-889c-486f-88f8-ee94100c7608 -> DATA/LINKFILES/YYYYMMDDHHMM/
|  |- 3cd9cb29-fd07-4c89-b9aa-15b5cd56d850 -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/
|  |- 8a99c65a-3104-4bd1-9ca3-0218cbdc993c -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/Bunch of directories with stupid names/
|  |- 7abae45b-dcff-4ea2-bdc3-cc2553faff0f -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/More stupidly named directories/
|  |- c0873272-3e3e-41fb-a2a1-240e19cf74b4 -> DATA/LINKFILES/yyyymmddhhmm/
|  |- 0adec7af-36ce-45ea-93a0-38327c9111e0 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/
|  |- 6753993d-be5d-412d-8ba0-28252b0cfa08 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/CTD/
|  |- 8281b40d-da48-4b2b-acba-0b9c79d563ee -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/XBT/
|  |- e24d23f9-1ba3-4e56-afcb-a5c7152ee437 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/Chlorophyll/

|- METADATA/
|  |- MANIFEST.txt           # global manifest of all files in system
|  |- MANIFEST.mdf           # } SQL database version of manifest 
|  |- MANIFEST.ldf           # }
|  |
|  |- YYYYMMDD-UUID/
|  |  |- metadata.xml        # metadata for accession - contains xlinks to PUBLICDATA/YYYYMMDD-UUID 
|  |
|  |- yyyymmdd-uuid/
|     |- metadata.xml        # metadata for accession - contains xlinks to PUBLICDATA/yyyymmdd-uuid 


```


## Glossary

*accession* is a bunch of related files.   
*collection* has no data: a superset describing a bunch of related accessions   
*dataset* informal term - often maps to accession, not always.   

