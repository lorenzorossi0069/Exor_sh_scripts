#!/bin/sh

FWDIR=/lib/firmware

sudo sh -c 'mount -o remount,rw /'

case $1 in

 ( mfg1 )
  sudo rm -rf $FWDIR/cypress
  sudo cp -r $FWDIR/cypress_mfg1 $FWDIR/cypress ;
  ls -la $FWDIR/cypress ;;

 ( rel1 )
  sudo rm -rf $FWDIR/cypress
  sudo cp -r $FWDIR/cypress_rel1 $FWDIR/cypress ;
  ls -la $FWDIR/cypress ;;

 ( * )
 echo "$0 [mfg1 | rel1]"
esac
