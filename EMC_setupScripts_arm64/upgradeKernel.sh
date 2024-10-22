#!/bin/sh

echo avvio
#SETUPDIR=/mnt/data
SETUPDIR=$PWD
echo SETUPDIR=$SETUPDIR

mount -o remount,rw /

if [[ ! -e $SETUPDIR/Image ]] ; then
	echo "Image not found in $SETUPDIR"
	exit 1
fi

echo "Replacing kernel Image?  "; echo "press y|Y to continue"; read upKernel
if [[ $upKernel != y ]] && [[ $upKernel != Y ]] ; then
	echo "exiting without update kernel"
	exit 1
fi

cd /boot
rm Image
cp $SETUPDIR/Image .
sync

echo "Press enter to reboot with new kernel"; read dummy

reboot

