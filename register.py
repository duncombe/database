
import hashlib
import uuid
import MySQLdb as mdb
import sys

m=hashlib.sha384()
# m.update("Nobody inspects")
# m.update(" the spammish repetition.\n")

UUID=uuid.uuid4()

if False:

    fh=open("CTD/db_CTD_data.mdf")

    for chunk in fh:
   	m.update(chunk)

    fh.close()

    print m.hexdigest()
    print UUID

def test_db():
    try:
        con = mdb.connect( 'localhost', 'testuser', 'test623', 'testdb',
    	unix_socket='/var/lib/mysql/mysql.sock');
    
        cur = con.cursor()
        cur.execute("SELECT VERSION()")
    
        ver = cur.fetchone()
        
        print "Database version : %s " % ver
        
    except mdb.Error, e:
      
        print "Error %d: %s" % (e.args[0],e.args[1])
        sys.exit(1)
        
    finally:    
     
        if con:    
            con.close()

test_db()

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

