#!/bin/bash
#
# Load/Unload Redpine RS9113 kernel modules
#

. /etc/default/rcS
. /etc/exorint.funcs

WIFI_SUPPORT=0

# Fastboot runs this script towards the end of rcS - block init invocation
[ "$ENABLE_FASTBOOT" = "yes" ] && [ $PPID -eq 1 ] && exit 0

# Check PLCM10 Module with integrated WIFI
WIFI_PLCM10=0
plcdev="$(modem dev)"
if [ ! -z ${plcdev} -a -e ${plcdev} ]; then
     funcarea="$(dd if=${plcdev}/eeprom skip=37 bs=1 count=1 2>/dev/null | hexdump -e '"%d"')"
     # check plcm eeprom for wifi bit
     if [ $(( ${funcarea} & 128 )) -eq 128 ]; then
         WIFI_PLCM10=1
     fi
fi

#Get specific gpio number for this platform and set WIFI_SUPPORT
if [ -e "/etc/default/wifi_gpio" ]; then
    . /etc/default/wifi_gpio
fi


if [ ${WIFI_PLCM10} -eq 0 ]; then
     [ ${WIFI_SUPPORT} -eq 0 ] && exit 0

     # Check WiFi disable bit in Jumper Flag Area
     [ "$( offsetjumperarea_bit 6 )" -eq 1 ] && [ "$(exorint_ver_carrier)" != "CA16" ] && exit 0

     # Check WiFi disable bit in SW Flag Area
     [ "$( exorint_swflagarea_bit 16 )" -eq 1 ] && exit 0
fi

load()
{

    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 1 > /sys/class/gpio/gpio$WIFI_GPIO/value
        #Don't unexport
        sleep 1
    fi;

# MOD_LR for Jsmart board with RS9113
if [ $(exorint_hwcode) == 139 ] ; then

    echo "Loading Redpine RS9113 modules" | logger

#    modprobe cfg80211
#    modprobe mac80211
#    modprobe rsi_91x
#    modprobe rsi_usb


    insmod /lib/modules/$(uname -r)/kernel/net/wireless/compat.ko
    insmod /lib/modules/$(uname -r)/kernel/net/wireless/cfg80211.ko
    insmod /lib/modules/$(uname -r)/kernel/net/mac80211/mac80211.ko
    insmod /lib/modules/$(uname -r)/kernel/crypto/cmac.ko
    insmod /lib/modules/$(uname -r)/kernel/crypto/gcm.ko
    insmod /lib/modules/$(uname -r)/kernel/crypto/ghash-generic.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_91x.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_usb.ko

    # Antenna int/ext mode is read from SEEPROM 30:0 - currently allocated for CAREL only
    if [ -z $ANTMODE ]; then
        ANTMODE=0 # default to internal antenna

        if [ "$(exorint_ver_carrier)" = "CA16" ]; then
            # Base antenna selection on seeprom byte 30
            "$(exorint_seeprom_byte 30)" = "1" ] && ANTMODE=1
        else
            # Base antenna selection on jumper area bit
            [ "$(offsetjumperarea_bit 5)" = "1" ] && ANTMODE=1
        fi

        # Use external antenna for PLCM
        [ ${WIFI_PLCM10} -eq 1 ] && ANTMODE=1
    fi
    echo "Detected ANTMODE: $ANTMODE (0:internal 1:external)" | logger --tag="wifi"
    iw phy phy0 set antenna ${ANTMODE} ${ANTMODE}

# MOD_LR for board ECO2XX or DA22 (at the moment only with AW)
elif [ $(exorint_hwcode) == 154 ] || [ $(exorint_hwcode) == 158 ] ; then

    echo "Loading CY4373 modules" | logger

    insmod /lib/modules/$(uname -r)/kernel/net/wireless/compat.ko
    insmod /lib/modules/$(uname -r)/kernel/net/wireless/cfg80211.ko
    #insmod /lib/modules/$(uname -r)/kernel/net/mac80211/mac80211.ko
    #insmod /lib/modules/$(uname -r)/kernel/crypto/cmac.ko
    #insmod /lib/modules/$(uname -r)/kernel/crypto/gcm.ko
    #insmod /lib/modules/$(uname -r)/kernel/crypto/ghash-generic.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
    #insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_91x.ko
    #insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_usb.ko

fi

}

unload()
{
    echo "UN-loading Redpine RS9113 modules" | logger --tag="wifi"

    rmmod cfg80211
    rmmod mac80211
    rmmod rsi_91x
    rmmod rsi_usb

    #wifi reset
    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 0 > /sys/class/gpio/gpio$WIFI_GPIO/value
        echo $WIFI_GPIO > /sys/class/gpio/unexport
        usleep 100000
    fi;
}

startPLCM10()
{
    echo "Starting PLCMxx wifi module" | logger --tag="wifi"
    $(modem wifion)
    sleep 1
}

case "$1" in
start)
    if [ ${WIFI_PLCM10} -eq 1 ]; then
        startPLCM10
    fi
    load
    ;;

stop)
    unload
    ;;

force-reload|restart)
    unload
    sleep 1
    load
    ;;

esac
