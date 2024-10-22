#!/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)

cd $MODULES_DIR

#sudo sh -c 'echo "---- loading  XXXXX module"> /dev/kmsg'

sudo insmod ecc.ko

sudo insmod ecdh_generic.ko

sudo insmod bluetooth.ko

sudo insmod btrtl.ko
sudo insmod btbcm.ko
sudo insmod btintel.ko

sudo insmod btusb.ko
