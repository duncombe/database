
import hashlib
import uuid
import MySQLdb as mbd

m=hashlib.sha384()
m.update("Nobody inspects")
m.update(" the spammish repetition.\n")
print m.hexdigest()

UUID= uuid.uuid4()

print UUID
