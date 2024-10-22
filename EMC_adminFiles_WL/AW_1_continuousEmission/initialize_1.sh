#!/bin/sh

#common initializations 1

pkill wpa_supplicant
pkill hostapd
ifconfig wlan0 up

#commands to be given with wl up
wl up
wl pkteng_stop tx
wl down

#commands to be given with wl down
wl frameburst 1
wl ampdu 1
wl country ALL
#wl rateset 11b
wl rateset 54b

wl bi 65000
wl phy_watchdog 0
  
wl mpc 0
wl txchain 1
wl mimo_bw_cap 1

#commands to be given with wl up
wl up
wl disassoc 
wl phy_forcecal 1
#wl txpwr1 -o 19
wl txpwr1 -o -1
wl down


