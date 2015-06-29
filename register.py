
import hashlib
m=hashlib.sha384()
m.update("Nobody inspects")
m.update(" the spammish repetition.\n")
print m.hexdigest()

m=hashlib.sha384("Nobody inspects the spammish repetition.\n")
print m.hexdigest()
