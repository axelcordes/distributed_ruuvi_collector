#!/bin/bash
#
# Startup Ruuvi Node Script (for crontab use)
#
result=`ps aux | grep -i "ruuvi_scan.sh" | grep -v "grep" | wc -l`
if [ $result -ge 1 ]
   then
        echo "Running Scanner detected, will be killed first!"
        # Number of seconds to wait before using "kill -9"
        WAIT_SECONDS=10
        
        PID=`pgrep ruuvi_scan.sh`

        # Counter to keep count of how many seconds have passed
        count=0

        while kill $PID > /dev/null
        do
          # Wait for one second
          sleep 1
          # Increment the second counter
          ((count++))

          # Has the process been killed? If so, exit the loop.
          if ! ps -p $PID > /dev/null ; then
              break
          fi

          # Have we exceeded $WAIT_SECONDS? If so, kill the process with "kill -9"
          # and exit the loop
          if [ $count -gt $WAIT_SECONDS ]; then
            kill -9 $PID
            break
         fi
       done
       echo "Process has been killed after $count seconds."
       echo "Starting: node"
        (/home/pi/distributed_ruuvi_collector/linux_node/ruuvi_scan.sh -m)
   else
        echo "Starting: node"
        (/home/pi/distributed_ruuvi_collector/linux_node/ruuvi_scan.sh -m)
fi