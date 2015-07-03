
from lxml import etree

root = etree.Element('metadata')

# print root.tag


root.append( etree.Element("title") )

child1=root[0]
child2=etree.SubElement(root,'summary')
child3=etree.SubElement(root,'keywords')
# , 'keywords']

# root.set("title","Title Text")
child2.set("summary_text","Summary Text")
child1.set("title_text","Title Text")

# print etree.tostring(root)
# ['title', 'summary', 'keywords']

name="Joseph Schmo"
phonenumber="+27 21 555 5999"

contactinfo=etree.Element("contact_info")
contactinfo.set("contact_name",name)
contactinfo.set("contact_phone",phonenumber)
contactinfo.text=name

phone=etree.SubElement(contactinfo,'phone')
phone.set("number",phonenumber)
phone.text=phonenumber

root.append(contactinfo)

print etree.tostring(root, pretty_print=True)

# file=open("MD-file.xml","w")
# tree=etree.XML(etree.tostring(root, pretty_print=True))
# tree=etree.XML(etree.tostring(root))
# tree.write("MD-file.xml", pretty_print=True)

file=open("MD-file.xml","w")
file.write(etree.tostring(root, pretty_print=True))
file.close

print "All done!\n"


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

