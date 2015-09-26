import os
import getopt
import sys
import uuid

def validate_uuid(Ustr):
# Ustr is a string purporting to be a version 4 UUID
    try:
        V=uuid.UUID(Ustr,version=4)
    except:
        # string is not a UUID of any description
        return False
    # string is or is not a valid v4 UUID
    Vstr=str(V)
    return Ustr == Vstr


# Ustr='7fa02323-2e44-5349-a74c-0423f0d4908a'
# 
# print validate_uuid(Ustr)
# 
# V=''
# print uuid.UUID(version=4)

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
   


if __name__ == "__main__":
   main(sys.argv[1:])


