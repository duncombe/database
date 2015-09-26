#! /home/duncombe/anaconda/envs/database/bin/python

from lxml import etree
import getopt
import uuid
import datetime
import sys
import os

# clear the screen?

def cls():
    # os.system(['clear','cls'][os.name == 'nt'])
    os.system('cls' if os.name=='nt' else 'clear')

# now, to clear the screen
cls()

def validate_uuid(Ustr):
# Ustr is a string purporting to be a version 4 UUID 
    try:
	# convert Ustr to a v4 UUID
        V=uuid.UUID(Ustr,version=4)
    except:
        # string is not a UUID of any description
        return False
    # string is or is not a valid v4 UUID
    return Ustr == str(V)

#####################################################
#####################################################

def main(argv):

   inputfile = outputfile = tablefile = None
   
   try:
      opts, args = getopt.getopt(argv,"hi:o:f:t:",
   	["help","ifile=","ofile=","file=","table="])
   except getopt.GetoptError:
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt in ("-h", "--help"):
         print 'test.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
      elif opt in ("-t", "--table"):
         tablefile = arg
      elif opt in ("-f", "--file"):
         inputfile = arg
         outputfile = arg
   
   
   print "Reading old metadata from:", inputfile
   print "Writing new metadata to:", outputfile
   print "Adding metadata from:", tablefile
   



# TODO: look at command line arguments. 
# take the uuid and date (accession number from the args or
# generate them. 
#
# as accession number 
# $ command_name "accession_date=UUID"
# 
# from a metadata file 
# $ command_name file
# 

import sys

# initialize
metadatafile=None
collectionID=None


# create_metadata.py
# 	-h : help
# 	-i : input metadata file (XML)
# 	-o : output metadata file 
# 	-f : read and write to the same file
# 	-t : read from a tab seperated table in the form
# 		Key\tValue
# 		Key and Value will be added to metadata in file
# 
# 


ARGS=sys.argv
OPTS=ARGS
del OPTS[0]

getopt.getopt(args, options[, long_options])

for arg in OPTS:
	if os.path.isfile(arg):
		metadatafile=arg

	if validate_uuid(arg):
		collectionID=uuid.UUID(arg)



if metadatafile is None:
	# crash or output to stdout
else
	# load in the input file


# file=open("MD-file.xml","w")

##### get this UUID from the catalog file or command line, or
# generate it for a new collection
#
# to generate a UUID for this collection
collectionID=str(uuid.uuid4()) 
# get a time for the accession
accdate=datetime.datetime.utcnow()

####

# accdatestring=accdate.__format__('%Y%m%dT%H%M')  

# Now we start to generate the xml tree 

# define the metadata schema
root = etree.Element('Metadata')

# root.append( etree.Element('fileIdentifier') )

#### begin of ingest metadata
#
# this is all standard, put it in a function
# that takes collection ID and date 

Ingest = etree.Element('accession')
AI=etree.SubElement(Ingest,'accessionDateTime')
AI.append( etree.Element('CharacterString') ) 
AI[0].text=accdate.isoformat()

AI=etree.SubElement(Ingest,'accessionUUID')
AI.append( etree.Element('CharacterString') ) 
AI[0].text=collectionID

AI=etree.SubElement(Ingest,'accessionIdentifier')
AI.append( etree.Element('CharacterString') ) 
AI[0].text='ocean.environment.gov.za:' + accdate.__format__('%Y%m%dT%H%M') \
	+ "=" + collectionID 

Contact=etree.SubElement(Ingest,'contact')
Contact.append( etree.Element( 'CI_responsibleParty' ) )
CI=Contact[0]
a=etree.SubElement(CI,'organizationName')
b=etree.SubElement(a,'CharacterString')

b.text='DEA/OC/OCR/OR > Oceans Research, Oceans and Coastal Research, ' \
	+ 'Oceans and Coasts, Department of Environmental Affairs'

a=etree.SubElement(CI,'positionName')
b=etree.SubElement(a,'CharacterString')
b.text='Data Officer'

a=etree.SubElement(CI,'contactInfo')
b=etree.SubElement(a,'CI_contact')
c=etree.SubElement(b,'phone')
d=etree.SubElement(c,'CI_telephone')
e=etree.SubElement(d,'voice')
f=etree.SubElement(e,'CharacterString')
f.text='+27-21-819-5003'

c=etree.SubElement(b,'address')
d=etree.SubElement(c,'CI_address')
e=etree.SubElement(d,'deliveryPoint')
f=etree.SubElement(e,'CharacterString')
f.text='East Pier'

e=etree.SubElement(d,'city')
f=etree.SubElement(e,'CharacterString')
f.text='Cape Town'

e=etree.SubElement(d,'administrativeArea')
f=etree.SubElement(e,'CharacterString')
f.text='Western Cape'

e=etree.SubElement(d,'country')
f=etree.SubElement(e,'CharacterString') 
f.text='South Africa'

e=etree.SubElement(d,'electronicMailAddress')
f=etree.SubElement(e,'CharacterString')
f.text='dataofficer@ocean.environment.gov.za'

a=etree.SubElement(CI,'role')
b=etree.SubElement(a,'CI_RoleCode')
b.set('codeList',"http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode")
b.set('codeListValue',"custodian")
b.text="custodian"

DS=etree.SubElement(Ingest,'dateStamp')
DS.append(etree.Element("DateTime"))
DS[0].text=accdate.isoformat()

#### end of ingest metadata


# <gmd:metadataStandardName><gco:CharacterString>ISO 19115-2 Geographic Information - Metadata - Part 2: Extensions for Imagery and Gridded Data</gco:CharacterString></gmd:metadataStandardName>
# <gmd:metadataStandardVersion><gco:CharacterString>ISO 19115-2:2009(E)</gco:CharacterString></gmd:metadataStandardVersion>


# Get a title (from the user)

# input title
Metadata=dict()
with open('ingest.data','r') as f :
	metadata=f.read()

metadict = dict(x.split(None,1) for x in metadata.splitlines())



Identification = etree.Element('IndetificationInfo')
IC = etree.SubElement(Identification,'citation')
a=etree.SubElement(IC,'title')
b=etree.SubElement(a,'CharacterString')
b.text=metadict['title']

a=etree.SubElement(IC,'abstract')
b=etree.SubElement(a,'CharacterString')
b.text=metadict['abstract']





root.append( Ingest )
root.append( Identification )


print etree.tostring(root, pretty_print=True, xml_declaration=True,
encoding="UTF-8")

# file=open("MD-file.xml","w")
# tree=etree.XML(etree.tostring(root, pretty_print=True))
# tree=etree.XML(etree.tostring(root))
# tree.write("MD-file.xml", pretty_print=True)

file=open("MD-file.xml","w")

file.write(etree.tostring(root, pretty_print=True))
file.close

# print "All done!\n"


# print etree.tostring(child2, pretty_print=True)

# children=list(root)
# for el in children:
# 	print el.tag



if __name__ == "__main__":
   main(sys.argv[1:])

### from ioos./compliance-checker
# 
#     def check_high(self, ds):
#         return ['title', 'summary', 'keywords']
# 
#     def check_recommended(self, ds):
#         return [
#             'id',
#             'naming_authority',
#             'keywords_vocabulary',
#             ('cdm_data_type', ['Grid', 'Image', 'Point', 'Radial', 'Station', 'Swath', 'Trajectory']),
#             'history',
#             'comment',
#             'date_created',
#             'creator_name',
#             'creator_url',
#             'creator_email',
#             'institution',
#             'project',
#             'processing_level',
#             'acknowledgment',
#             'geospatial_lat_min',
#             'geospatial_lat_max',
#             'geospatial_lon_min',
#             'geospatial_lon_max',
#             'geospatial_vertical_min',
#             'geospatial_vertical_max',
#             'time_coverage_start',
#             'time_coverage_end',
#             'time_coverage_duration',
#             'time_coverage_resolution',
#             'standard_name_vocabulary',
#             'license'
#         ]
# 
#     def check_suggested(self, ds):
#         return [
#             'contributor_name',
#             'contributor_role',
#             'publisher_name',       # publisher,dataCenter
#             'publisher_url',        # publisher
#             'publisher_email',      # publisher
#             'date_modified',
#             'date_issued',
#             'geospatial_lat_units',
#             'geospatial_lat_resolution',
#             'geospatial_lon_units',
#             'geospatial_lon_resolution',
#             'geospatial_vertical_units',
#             'geospatial_vertical_resolution',
#             'geospatial_vertical_positive'
#         ]
# 
# vi: se nowrap tw=0 :

