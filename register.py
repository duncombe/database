
import hashlib
import uuid
import MySQLdb as mbd



m=hashlib.sha384()
# m.update("Nobody inspects")
# m.update(" the spammish repetition.\n")

UUID=uuid.uuid4()


fh=open("CTD/db_CTD_data.mdf")

for chunk in fh:
	m.update(chunk)

print m.hexdigest()
print UUID


