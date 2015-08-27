# database

A test suite for creating an accession in a simple database.  Includes
rudimentary tools to assign UUIDs, calculate SHA checksums and add files to the
database (from a set of web-accessible folders (WAFs)).  This initial pass at
the problem is intended to create an emergency database that can easily be
incorporated into a more mature product as one becomes available.

## Workflow
Ingest flow is anticipated to be as follows:

1. A suite of data, or dataset, is acquired consisting of files arranged in some provider defined directory structure. Files may be of any type. Metadata in XML or JSON files may or may not be present. (Remember: collections do not have their own files!)

2. In ISO-14721 terminology, this suite is termed a Submission Information Package (SIP) and is assigned an accession number.

   1. The accession number should be of the form YYYYMMDD:UUID, with the first eight digits indicating the date the dataset was ingested into the system, and the next section, a unique number. (Using solely date-based information can cause collisions.)
1. The accession is assigned a UUID. If you really want something that can be automatically generated, then use the UUID, but I warn you, people will get frustrated because UUIDs are not memorable, so I would preface it with the date, like this:
YYYYMMDD:UUID


        That is both unique, able to be automatically generated, and enough of it is memorable so that people can have some clue about how to look up something they were working on by accession number.


1. The UUID and accession-level metadata are stored in an accession information table (Are you really going to use an ASCII TSV for metadata?)
   1. initially in a TSV ASCII table
   2. later converted to SQL table database.
1. The directory structure is read.
2. For each file in the collection, the SHASUM -a384 is calculated and the file copied to a second database structure, ${DATABASE}/ which is organized according to the SHA digest. E.g., a file with shasum of 38b060a751ac96384 …  might be stored as
3. ${DATABASE}/3/8b060a751ac96384 ....
4. A UUID is assigned to each file in the second database and added to another files table in the MySQL database. Save UUIDs for AIPs.  You don’t need one for each file!
   1. The files table has the following three pieces of information
      1.  the accession number which incorporates the UUID
      2.  the SHAsum
      3. the original filename and path
   1. The AIP entry has the following four pieces of information in it
      1. the accession number with UUID
      2. the accession number of any parent collection(s)
      3. the accession number of any child collection(s)
      4. the filename of the XML file with the metadata describing the AIP.
      5. the filename of the manifest containing all of the filenames in an AIP.


INGEST/
|  |- YYYYMMDDHHMM/
|  |  |- My special data set/
|  |     |- Bunch of directories with stupid names/
|  |     |- More stupidly named directories/
|  |        |- Worse - named-file'_s with bad! punctuation & spelling
|  |- yyyymmddhhmm/
|     |- Cruise 321/
|        |- CTD/
|        |- XBT/
|        |- Chlorophyll/
[a]|           |- chladata.xls




|- DATABASE/
|  |- 00/
|  |  |- 00/
|  |  |  |- 00/
|  |  |  |- 01/ 
|  |  |     |- f0128adfea073e ... 12ff # shasum named file -
|  |  |                                # this file has shasum-384 of
|  |  |                                # 000001f0128adfea073e...12ff
|  |  |- 01/ 
.  .  .      
.  .  .      
.  .  .      
|  |- 38/
|  |  |- b0/
|  |     |- 60/
|  |        |- a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
|  |- 39/
|  |- 3a/
|  .
|  .
|  .`
|  |- fe/
|  |- ff/ 
|
|- LINKFILES
[b]|  |- YYYYMMDDHHMM/
|  |  |- My special data set/
|  |     |- Bunch of directories with stupid names/
|  |     |- More stupidly named directories/
|  |        |- Worse - named-file'_s with bad! punctuation & spelling --> DATA/DATABASE/00/00/01/f01...12ff
|  |- yyyymmddhhmm/
|     |- Cruise 321/
|        |- CTD/
|        |- XBT/
|        |- Chlorophyll/
|           |- chladata.xls -> DATA/DATABASE
|
|- UUIDLINKS/
[c]   |- 8584e980-889c-486f-88f8-ee94100c7608 -> DATA/LINKFILES/YYYYMMDDHHMM/
  |- 3cd9cb29-fd07-4c89-b9aa-15b5cd56d850 -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/
  |- 8a99c65a-3104-4bd1-9ca3-0218cbdc993c -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/Bunch of directories with stupid names/
  |- 7abae45b-dcff-4ea2-bdc3-cc2553faff0f -> DATA/LINKFILES/YYYYMMDDHHMM/My special data set/More stupidly named directories/
  |- c0873272-3e3e-41fb-a2a1-240e19cf74b4 -> DATA/LINKFILES/yyyymmddhhmm/
  |- 0adec7af-36ce-45ea-93a0-38327c9111e0 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/
  |- 6753993d-be5d-412d-8ba0-28252b0cfa08 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/CTD/
  |- 8281b40d-da48-4b2b-acba-0b9c79d563ee -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/XBT/
  |- e24d23f9-1ba3-4e56-afcb-a5c7152ee437 -> DATA/LINKFILES/yyyymmddhhmm/Cruise 321/Chlorophyll/


________________


DEIRDRE’S EXAMPLE


You have three filesystems: an ingest area, where SIPs are assembled into AIPs. [d][e][f]An archive area, where AIPs are stored.  A backup system for the archive area, and finally, a dissemination filesystem, where some kind of human-parseable structure and filenames are maintained (DIPs).


Here is a mockup of the first one:


INGEST/
        YYYYMMDD:UUID/ <- container for SIP in the ingest area
ABOUT/
MANIFEST.TXT <- text file with list of all files in /DATA/ and their SHA digests, listing their original file structure and filenames. At the top of the manifest, the accession number and UUID of this SIP/AIP.
METADATA.XML (?) <- does not actually need to be stored here, but it could be. This allows you to update the metadata without having to alter the manifest or anything in /DATA/.
DATA/
                SUBMITTED/ <- under here is everything as submitted
My special data set/
                        Bunch of directories with stupid names/
                        More stupidly named directories/
                        File'_s with bad! punctuation & spelling
                                Cruise 321/
                                        CTD/
                                        XBT/
                                        Chlorophyll/
                                                chladata.xlsx
EXTRA/ <- NODC has a directory for files that are translated - from .docx to .pdf, for example.  This is a useful container.  
          It does not have to be in the manifest, as it is not exactly archival data ... but it could be.


YYYYMMDD:UUID/ <- another SIP in the ingest area …..




ARCHIVE/
                00/00/01
                        0f0128adfea073e ... 12ff # shasum named file -
                        # this file has shasum-384 of
                        # 000001f0128adfea073e...12ff
.  .  .      
.  .  .      
.  .  .      
|  |- 3/
380a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
|  .
|  .
|  .`
|  |- f/ 
[g][h][i][j][k]

In addition I would have a special “backup” area where you have made a tarball of the accession (SIP or AIP) from the ingest area.  So you have YYYYMMDD:UUID.tar, and inside it, the metadata, manifest, and originally named files in the original filesystem structure.  This can be written to tape for disaster recovery.  IF the accession is a large one, the --tape-length argument can be used to segment the AIP.






 toplevel.jpg 













(this below is your dissemination area)


PUB/


YYYYMMDD:UUID/symlinks to DATA virtually arranged in same structure as in the ingest area


[a]Please see my alternate example on page below.
[b]I don't understand what this is.
[c]I don't understand what this is.
[d]Seems to me this is a working directory which is not part of the data base at all.
[e]Well, it's where you receive and first unpack datasets.  It is the area from which you arrange the SIP into an AIP.  I guess I am thinking of the whole system and this is an integral part.
[f]Speaking of that, where ya gonna store the ISO metadata and manifest?
[g]To begin with, you certainly don't need any more than 16 partitions, so use first digit only.  Assume 2 TB partitions.
[h]These are not partitions, they are directories. If you try with only half a byte, ie 16 directories, pretty soon you have directories with 10^3, or 10^4 entries. These are extremely slow to read. Nesting the subdirectories the way I did it allows about 256^3 files before you need to worry about directories getting more than 256 entries, a manageable number.
[i]10^3 or 10^4 is okay.  10^5 is not.
[j]But I would start them out as partitions.
[k]I would still  like to keep the directory listings small, so split them 
across the partitions however you like. In any case this server does not 
have many many partitions anyway.
