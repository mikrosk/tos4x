#
# script to check in all source files
#
echo -n "Enter version number: "
set vers=$<
echo -n "Enter version message: "
set descr=$<
set files="*.[csh] *.inf makeprg changes *.inp"
ci "-l$vers" -f "-m$descr" $files
unset vers descr files

