uuid=`uuidgen -r`
echo "# Test database catalog"
echo "# SHASUM	UUID	Filename"
cat "$@" | shasum -a 384 | sed 's/-/'$uuid' /' 


