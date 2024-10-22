#!/bin/sh

#===add current path (and find here wl command)===
PATH=$PATH:$(pwd)
if [[ ! -e ./wl ]] ; then
  echo "wl not found in current folder, please copy or link wl here"
  exit 1
fi

# #===search library in two paths===
# if [[ -e ./libWl.sh ]] ; then
#   source ./libWl.sh
#   echo "library found in current folder"
# #elif [[ -e ../lib_AW/libWl.sh ]] ; then
# #  source "../lib_AW/libWl.sh"
# #  echo "library found in lib_AW folder"
# else
#   echo "library file not found"
#   exit 1
# fi

if [[ $1 == '' ]] ; then 
  echo "insert channel"
  exit 1
fi


ifconfig wlan0 up
trap terminateEmission SIGINT


wl down
wl country ALL
wl band b
wl mpc 0
wl up
wl out

wl fqacurcy $1 

# to stop tx select ch 0
echo "press any key to stop (select ch 0)"
read dummyVal
wl fqacurcy 0
wl down
wl up

