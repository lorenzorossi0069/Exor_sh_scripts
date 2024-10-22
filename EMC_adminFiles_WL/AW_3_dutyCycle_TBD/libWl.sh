#wl functions library

list_2G_w20=(1 2 3 4 5 6 7 8 9 10 11 12 13)
list_2G_w40=(3 4 5 6 7 8 9 10 11)

list_5G_w20=(36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 144 149 153 157 161 165)
list_5G_w40=(38 46 54 62 102 110 118 126 134 142 151 159)
list_5G_w80=(42 58 106 122 138 155)
  
function terminateEmission {
  wl up
  wl pkteng_stop tx
  wl down
  exit 
}

function restartStoppedEmission {
  wl up
  wl pkteng_stop tx
  wl pkteng_start 00:11:22:33:44:55 tx 20 1500 0
}
	
function setRawChannel {
	if (($# < 5)) ; then
		echo "must specify 5 args: <ch>:$1 <band>:$2 <bw>:$3 <sideband>:$4 <standard>:$5"
		
	else
		echo "<ch>:$1 <band>:$2 <bw>:$3 <sideband>:$4 <standard>:$5"
		wl up	
		wl pkteng_stop tx	
		
		wl chanspec -c $1  -b $2  -w $3   -s $4 
		
		if [[ $5 == 'a' ]]  ; then 
			wl 5g_rate -r 6
			
		elif [[ $5 == 'b' ]]   ; then 
			wl 2g_rate -r 1
			
		elif [[ $5 == 'g' ]]    ; then  
			wl 2g_rate -r 6
			
		elif [[ $5 == 'n' ]] && (( $2 == 2 ))  ; then  
			wl 2g_rate -h 0 -b $wx
			
		elif [[ $5 == 'n' ]] && (( $2 == 5 ))  ; then  
			wl 5g_rate -h 0 -b $wx
					
		elif [[ $5 == 'ac' ]] ; then	
			wl 5g_rate -v 0x1 -b 80
		fi
				
		if [[ $5=='b' ]] ; then
			wl pkteng_start 00:11:22:33:44:55 tx 20 500 0
		else
			wl pkteng_start 00:11:22:33:44:55 tx 20 1500 0
		fi
	fi
}


function setChannel {
	if (( $# < 2 || $# >3 )) ; then
		echo "ERR: $# is a wrong number of arguments, syntax is:"
		echo "chanspec <channel> <bandwidth> [standard: <b|g|[n]|a|[ac]>]"
		terminateEmission
		exit 1
	fi
	
	cx=$1  #channel
	wx=$2  #bandwidth
	stx=$3 #standard: b g n a ac
	
	#guess band based on channel number
	if (($cx<20)) ; then 
		bx=2
		wl band b
	else 
		bx=5
		wl band a
	fi
	
	sx=0
	
	#set datarate according to standard stx, band bx and bandwidth wx
	if [[ $stx == 'a' ]] && (( $bx == 5 )) && (( $wx == 20 )) ; then 
		#standard 802.11 a does not allow bw >20
		wl 5g_rate -r 6
		
	elif [[ $stx == 'b' ]] && (( $bx == 2 )) && (( $wx < 40))  ; then 
		wl 2g_rate -r 1
		
	elif [[ $stx == 'g' ]]  && (( $bx == 2 )) && (( $wx < 40))  ; then  
		wl 2g_rate -r 6
		
	elif [[ $stx == 'n' ]] && (( $bx == 2 )) ; then  
		wl 2g_rate -h 0 -b $wx
		
	elif [[ $stx == 'n' ]] && (( $bx == 5 )) && (( $wx < 80))  ; then  
		#standard 802.11 n for 5G does not allow bw > 40
		wl 5g_rate -h 0 -b $wx
				
	elif [[ $stx == 'ac' ]] && (( $bx == 5 )) ; then	
		wl 5g_rate -v 0x1 -b 80
				
	elif [[ $stx == '' ]] && (( $bx == 2 )) ; then
		stx=n
		#set default 2G n40
		wl 2g_rate -h 0 -b 40
		
	elif [[ $stx == '' ]] && (( $bx == 5 )) ; then
		stx=ac
		#set default 5G ac VHT80
		wl 5g_rate -v 0x1 -b 80
		
	else
		echo "ERR: invalid standard $stx for band ${bx}G and bandwidth $wx"
		terminateEmission
		exit 1
	fi
	
	
			
	if (( $bx == 2 )) ; then

		if ! ( ( (( $wx == 20)) && ( containsElement "$cx" "${list_2G_w20[@]}" ) ) \
	     ||    ( (( $wx == 40)) && ( containsElement "$cx" "${list_2G_w40[@]}" ) ) ) ; then
		 
			echo "ERR: invalid values: channel:$cx , bandwidth:${wx}MHz,  band:${bx}G"
			terminateEmission
			exit 1
		fi  
		
		
			
	elif (( $bx == 5 )) ; then
		if ! ( ( (( $wx == 20)) && ( containsElement "$cx" "${list_5G_w20[@]}" )  )  \
		 ||    ( (( $wx == 40)) && ( containsElement "$cx" "${list_5G_w40[@]}" )  )  \
		 ||    ( (( $wx == 80)) && ( containsElement "$cx" "${list_5G_w80[@]}" )  )  )  ; then
		
			echo "invalid wx=$wx cx =$cx"
			echo "ERR: invalid values: channel $cx, bandwidth ${wx}MHz for band ${bx}G"
			terminateEmission
			exit 1
		fi
	
	else 
		echo "band ${bx}G is not valid"
	fi
	
 
	wl up	
	wl pkteng_stop tx	
	echo "Band ${bx}G , channel $cx , bandwidth ${wx}MHz , standard $stx"
	wl chanspec -c $cx   -b $bx   -w $wx   -s $sx
	if [[ $stx==b ]] ; then
		wl pkteng_start 00:11:22:33:44:55 tx 20 500 0
	else
		wl pkteng_start 00:11:22:33:44:55 tx 20 1500 0
	fi
}

function setPower {
	wl txpwr1 -o -$1
	echo "Power set to ${wl txpwr1}"
}

function getPower {
	echo "Power is ${wl txpwr1}"
}


function scanAll_2G {
  w=$1
  scanAllParametric 2 $w
}


function scanAll_5G {
  w=$1
  scanAllParametric 5 $w
}

function scanAllParametric { #b #w
  b=$1
  w=$2
  echo
  echo
  
  if (( $b==5 )) ; then
    if (( $w==20)) ; then
      list="${list_5G_w20[@]}"
    elif (( $w==40)) ; then
      list="${list_5G_w40[@]}"
    elif (( $w==80)) ; then
      list="${list_5G_w80[@]}"
    else
      echo "only 20 40 or 80 MHz bandwidth is allowed"
	  terminateEmission
      exit 1
    fi
	echo "list $w : $list"
  elif (( $b==2 )) ; then
   if (( $w==20)) ; then
      list="${list_2G_w20[@]}"
    elif (( $w==40)) ; then
      list="${list_2G_w40[@]}"
    else
      echo "only 20 40 allowed"
	  terminateEmission
      exit 1
	fi
  fi
    
  for cx in $list
  do
    echo  "showing ch $cx"
    wl pkteng_stop tx
    wl chanspec -c $cx -b $b -w $w -s 0 
    wl pkteng_start 00:11:22:33:44:55 tx 20 1500 0
    echo  "press ENTER for next channel"
    echo
    read -n 1 -s -r -u3 
  done
  
  echo "press ENTER to terminate"
  read -n 1 -s -r -u3   #3 is a redirection of stdin (0)
}


function containsElement {
	# --! be careful modifying this function: it might make stuff not working !--
    local x="$1"
    shift
    for listElement in "$@" ; do
		if [[ "$listElement" == "$x" ]]; then
			return 0
		fi
    done
    return 1  
}
