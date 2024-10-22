#!/bin/sh

source ./upgradeFunctions.sh

SETUPDIR=$PWD

mount -o remount,rw /

#create folders (if not yet)
createUnexistingFolder /lib/firmware/cypress
createUnexistingFolder /lib/modules/$(uname -r)/kernel/net/wireless
## createUnexistingFolder /lib/modules/$(uname -r)/kernel/net/mac80211

#copy files to folders
movefileTo /lib/modules/$(uname -r)/kernel/net/wireless  compat.ko
movefileTo /lib/modules/$(uname -r)/kernel/net/wireless  cfg80211.ko
## movefileTo /lib/modules/$(uname -r)/kernel/net/mac80211  mac80211.ko
## movefileTo /lib/modules/$(uname -r)/kernel/crypto cmac.ko
## movefileTo /lib/modules/$(uname -r)/kernel/crypto gcm.ko
## movefileTo /lib/modules/$(uname -r)/kernel/crypto ghash-generic.ko
movefileTo /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil brcmutil.ko
movefileTo /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac brcmfmac.ko
movefileTo /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi rsi_91x.ko
movefileTo /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi rsi_usb.ko

movefileTo /lib/firmware/cypress cyfmac4373.bin
movefileTo /lib/firmware/cypress cyfmac4373.clm_blob

sync

#update wifi_gpio
updateFileAndCheck /etc/default  wifi_gpio

#update networking_rs911xkernel.sh
echo "now working in $PWD"
updateFileAndCheck  /etc/init.d  networking_rs911xkernel.sh

echo "==========================="
echo "PROGRAM COMPLETED CORRECTLY"
echo "==========================="
sync

echo -n  " enter any key to reboot "; read dummy
reboot


