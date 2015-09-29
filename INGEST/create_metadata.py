#! /home/duncombe/anaconda/envs/database/bin/python 

from lxml import etree
import getopt
import uuid
import datetime
import dateutil.parser
import sys
import os
import getpass

# clear the screen?

def cls():
    # os.system(['clear','cls'][os.name == 'nt'])
    os.system('cls' if os.name=='nt' else 'clear')

# now, to clear the screen
cls()

################################################################

def IDdateformat(DateTimeObject):
    return DateTimeObject.__format__('%Y%m%dT%H%M')

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


def argument_help():
	helptext=[" ", 
sys.argv[0]+" -h [[-i file] [-o file]] | [-f file] [-t file] [[[-u] [-d]] | -a]",
"  	-h : help",
"  	-i : input metadata file (XML)",
"  	-o : output metadata file ",
"  	-f : read and write to the same file",
"  	-t : read from a tab seperated table in the form",
"  		Key\\tValue",
"  		Key and Value will be added to metadata in file",
"	-u : uuid for the collection",
"	-a : accession string for the collection",
"	-d : accession date for the collection"]
	for i in helptext:
		print i
  	exit()
  

#####################################################
# 
# main function
# 
#####################################################

def main(argv):

   root = accdate = collectionID = inputfile = outputfile = tablefile = \
	None
   
   try:
      opts, args = getopt.getopt(argv,"hi:o:f:t:u:a:d:",
   	["help","ifile=","ofile=","file=","table=","uuid=",
            "accession=", "date="])
   except getopt.GetoptError:
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt in ("-h", "--help"):
         argument_help()
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
      elif opt in ("-u", "--uuid"):
	 if validate_uuid(arg):
	    collectionID=uuid.UUID(arg)
         else:
            print arg, "was provided as a UUID, but is not a valid v4 UUID."
            print "A valid v4 UUID will be generated."
      elif opt in ("-a", "--accession"):
         accdate=arg.split("=")[0]
         collectionID=arg.split("=")[1]
      elif opt in ("-d", "--date"):
         accdate=arg
      
   # regurgitate arguments
   print "Reading old metadata from:", inputfile
   print "Writing new metadata to:", outputfile
   print "Adding metadata from:", tablefile
   print "UUID:", collectionID
   print "Date:", accdate

   # open up tablefile and load up the elements therein
   # if an element already exists, replace or add to it from the 
   # table as we go along

   # at present only keys are title and abstract

   metadata=dict()
   if tablefile is not None:
   	with open(tablefile,'r') as f:
   		metadata=f.read()
   
   metadict = dict(x.split(None,1) for x in metadata.splitlines())
   
   

   if inputfile is not None:
	# load in the input file
	# infile=open(inputfile,"r")
	root = etree.parse(inputfile)
	# find the uuid (collectionID) and accdate in root
	for e in root.iterfind('*/accessionDateTime/CharacterString'):
		accdate=e.text
	for e in root.iterfind('*/accessionUUID/CharacterString'):
		collectionID=e.text

   # if collectionID was not in the metadata file or on the command line
   # generate it for a new collection
   if collectionID is None: 
      collectionID=str(uuid.uuid4()) 

   # get a time for the accession
   if accdate is None:
      accdate=datetime.datetime.utcnow()

   ####

   # accdatestring=accdate.__format__('%Y%m%dT%H%M')  


   # Now we start to generate the xml tree 

   # define the metadata schema
   if root is None:
   	root = etree.Element('Metadata')
   
   # root.append( etree.Element('fileIdentifier') )

   #### begin of ingest metadata
   #
   # this is all standard, put it in a function
   # that takes collection ID and date 

   # populate ingest information

   D=dateutil.parser.parse(accdate)

   ingest = root.find('accession') 
   if Ingest is None:
   	Ingest = etree.Element('accession')

   AI = Ingest.find('accessionDateTime')
   if AI is None:
   	AI=etree.SubElement(Ingest,'accessionDateTime')

   CS = AI.find('CharacterString')
   if CS is None:
	AI.append( etree.Element('CharacterString') ) 
   	AI[0].text=accdate.isoformat()

   AI = Ingest.find('accessionUUID')
   if AI is None:
	AI=etree.SubElement(Ingest,'accessionUUID')
	AI.append(etree.Element('CharacterString')) 
	AI[0].text=collectionID

   AI = Ingest.find('accessionIdentifier')
   if AI is None:
	AI=etree.SubElement(Ingest,'accessionIdentifier')
   	AI.append( etree.Element('CharacterString') ) 
   	AI[0].text='ocean.environment.gov.za:' + IDdateformat(accdate) \
   	+ "=" + collectionID 

   Contact = Ingest.find('contact')
   if Contact is None:
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

   DS = Ingest.find(dateStamp) 
   if DS is None:
	DS=etree.SubElement(Ingest,'dateStamp')

   DS.append(etree.Element("DateTime",modified_by=getpass.getuser()))
   DS[-1].text=datetime.datetime.utcnow().isoformat()
   
   #### end of ingest metadata
   
   
   # <gmd:metadataStandardName><gco:CharacterString>ISO 19115-2 Geographic Information - Metadata - Part 2: Extensions for Imagery and Gridded Data</gco:CharacterString></gmd:metadataStandardName>
   # <gmd:metadataStandardVersion><gco:CharacterString>ISO 19115-2:2009(E)</gco:CharacterString></gmd:metadataStandardVersion>
   
   
   # Get a title (from the user) 

  
   Identification = root.find('IdentificationInfo')
   if Identification is None: 
   	Identification = etree.Element('IdentificationInfo')

   IC = Identification.find('citation')
   if IC is None:
	IC = etree.SubElement(Identification,'citation')


   a=IC.find('title')
   if a is None:
   	a=etree.SubElement(IC,'title')
	if 'title' in metadict:
   		b=etree.SubElement(a,'CharacterString')
   		b.text=metadict['title']
	else:
		title=input("Provide a collection title: ")
   		b=etree.SubElement(a,'CharacterString')
   		b.text=title

   a=IC.find('abstract')
   if a is None:
   	a=etree.SubElement(IC,'abstract')
	if 'abstract' in metadict:
   		b=etree.SubElement(a,'CharacterString')
   		b.text=metadict['abstract']
	else:
		abstract=input("Provide a collection abstract: ")
   		b=etree.SubElement(a,'CharacterString')
   		b.text=abstract


   root.append( Ingest )
   root.append( Identification )


   print etree.tostring(root, pretty_print=True, xml_declaration=True,
   encoding="UTF-8")
   
   # file=open("MD-file.xml","w")
   # tree=etree.XML(etree.tostring(root, pretty_print=True))
   # tree=etree.XML(etree.tostring(root))
   # tree.write("MD-file.xml", pretty_print=True)
   
   # file=open("MD-file.xml","w")
   file=open("testfile.xml","w")
   
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

