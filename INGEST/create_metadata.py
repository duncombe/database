
from lxml import etree
import uuid
import datetime

# TODO: look at command line arguments. 
# take the uuid and date (accession number from the args or
# generate them. 

# clear the screen?

import os

def cls():
    # os.system(['clear','cls'][os.name == 'nt'])
    os.system('cls' if os.name=='nt' else 'clear')

# now, to clear the screen
cls()

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

