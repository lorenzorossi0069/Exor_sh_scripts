#!/bin/sh

#===add current path (and find here wl command)===
PATH=$PATH:$(pwd)
if [[ ! -e ./wl ]] ; then
  echo "wl not found in current folder, please copy or link wl here"
  exit 1
fi

#===search library in current path 
# or otherwise in library folder===
if [[ -e ./libWl.sh ]] ; then
  source "./libWl.sh"
  #echo "library found in current folder"
#elif [[ -e ../lib_AW/libWl.sh ]] ; then
#  source "../lib_AW/libWl.sh"
#  echo "library found in lib_AW folder"
else
  echo "library file not found"
  exit 1
fi

trap terminateEmission SIGINT

./initialize_1.sh

setChannel $@


echo "press q to stop emission (any other key to keep alive)"
read var
if [[ $var == 'q' ]] ; then
	terminateEmission
fi

  

#eof

