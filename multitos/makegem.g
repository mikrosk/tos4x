#
# csh script file for building the AES
# execute with "source makegem"
# 
set foo $PATH
setenv PATH f:\bin,c:\mint\bin
rehash
make -f makeprg
setenv PATH "$foo"
rehash
unset foo
