#!/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)
cd $MODULES_DIR

sudo rmmod btusb.ko
sudo rmmod btintel.ko
sudo rmmod btbcm.ko
sudo rmmod btrtl.ko
sudo rmmod bluetooth.ko
sudo rmmod ecdh_generic.ko
sudo rmmod ecc.ko




