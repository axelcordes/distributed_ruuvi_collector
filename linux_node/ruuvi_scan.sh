#!/bin/bash
#
# Modified script of https://gist.github.com/elliotlarson/1e637da6613dbe3e777c
#
# Usage 
# 1. Set Defines
# 2. Call script:
#		no options: full information output
#		-r		  : less information output
#       -m        : send data to MQTT Broker (Node ID, Beacon MAC, RSSI, TIMESTAMP, PALOAD
#       -v        : show whole BT telegram
#       -p        : payload output


#
# Requirements: bc mosquitto-clients bluez-hcidump
#

 

#
# Defines
#
SCAN_DEVICE=hci0                          # define which BT dongle is used

SCAN_FILTER=".{56}FF\ 99\ 04"   # filter ruuvi tags
RSSI_TRESHOLD=-100                         # Consider beacons only if RSSI is greater than treshold
MQTT_BROKER=localhost
MQTT_CHANNEL=ruuvis
#
# End: Defines
#


# Get rid of stack size limit
#echo "Stack size before start: `ulimit -s`"
#ulimit -s unlimited
#echo "Stack size run mode: `ulimit -s`"

#
# MAIN
#
# Get MAC of BT Scanner
NODE=`hciconfig $SCAN_DEVICE | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' `

# Process:
# 1. start hcitool lescan
# 2. begin reading from hcidump
# 3. packets span multiple lines from dump, so assemble packets from multiline stdin
# 4. for each packet, process
# 5. when finished (SIGINT): make sure to close out hcitool

halt_hcitool_lescan() {
  sudo pkill --signal SIGINT hcitool
}


trap halt_hcitool_lescan INT

process_complete_packet() (
  packet=${1} # For DEBUG
  #echo $packet
  if [[ $packet =~ ^$SCAN_FILTER ]]; then      
    #echo $packet    # For DEBUG 
	if [[ $2 == "-r" ]]; then
	  RSSI=`echo $packet | sed 's/.*\(..\)/\1/' ` # last byte
	  RSSI=`echo "ibase=16; $RSSI" | bc`
	  RSSI=$[RSSI - 256]
	  MAC1=`echo $packet | sed 's/^.\{38\}\(.\{2\}\).*$/\1/'`  
	  MAC2=`echo $packet | sed 's/^.\{35\}\(.\{2\}\).*$/\1/'`
	  MAC3=`echo $packet | sed 's/^.\{32\}\(.\{2\}\).*$/\1/'`
	  MAC4=`echo $packet | sed 's/^.\{29\}\(.\{2\}\).*$/\1/'`
	  MAC5=`echo $packet | sed 's/^.\{26\}\(.\{2\}\).*$/\1/'`
	  MAC6=`echo $packet | sed 's/^.\{23\}\(.\{2\}\).*$/\1/'`
	  MAC="$MAC1:$MAC2:$MAC3:$MAC4:$MAC5:$MAC6"
	  echo "$MAC $RSSI"
	elif [[ $2 == "-m" ]]; then
	  mosquitto_pub -h $MQTT_BROKER -t $MQTT_CHANNEL -m "$packet"
	  echo "$packet" #debug 
  fi
    #fi
  fi
)

read_blescan_packet_dump() {
  # packets span multiple lines and need to be built up
  packet=""
  while read line; do
    # packets start with ">"
    if [[ $line =~ ^\> ]]; then
      # process the completed packet (unless this is the first time through)
      if [ "$packet" ]; then
        process_complete_packet "$packet" $1 
      fi
      # start the new packet
      packet=$line
    else
      # continue building the packet
      packet="$packet $line"
    fi
  done
}

# begin BLE scanning
sudo hcitool -i $SCAN_DEVICE lescan --duplicates > /dev/null &
sleep 1
# make sure the scan started
if [ "$(pidof hcitool)" ]; then
  # start the scan packet dump and process the stream
  sudo hcidump --raw | read_blescan_packet_dump $1
else
  echo "ERROR: it looks like hcitool lescan isn't starting up correctly" >&2
  exit 1
fi

#
# End: Main 
#
