#!/bin/sh

#===add current path (to find wl command)===
PATH=$PATH:$(pwd)


#===search library first in current path 
# and else in library folder===
if [[ -e ./libWl.sh ]] ; then
  source "./libWl.sh"
#  echo "library found in current folder"
#elif [[ -e ../lib_AW/libWl.sh ]] ; then
#  source "../lib_AW/libWl.sh"
#  echo "library found in lib_AW folder"
else
  echo "library file not found"
  exit 1
fi


restartStoppedEmission


