#
# script to check in a new version
# NOTE: this script works only under MultiTOS
#
echo "Last RCS version number was:" `cat lastvers`
echo -n "Enter version number: "
set vers=$<
echo -n "Enter version message: "
set descr=$<
set files=`cat ci.lis`
ci "-l$vers" -f "-m$descr" $files
#
# binary files must be copied verbatim
#
echo "Copying binary files..."
mkdir rcs.bin\$vers
set files=`cat cp.lis`
cp $files rcs.bin\$vers
#
# all done
#
echo $vers >lastvers
unset vers descr files
