# Node (linux)
Scanner Script for Linux Nodes (e. g. Raspberry Pi).
I recommend not to use a Pi Zero in BLE crowdy conditions. I had several "segfaults" during operations with a Zero. I think, this is related to the single core processor on the Pi Zero since I have no Problems with Pi  version 3 running this script.

## Requirements
For Raspberry Pi
<pre><code>sudo apt-get install bc mosquitto-clients bluez-hcidump sed</code></pre>
Edit the script and change mqtt broker information according your network setup.

## Operation - Manual start
<pre>./ruuvi_scan.sh [Parameter]<code>
</code></pre>
Parameters
<table class="tg">
  <tr>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Description</th>
  </tr>
  <tr>
    <td class="tg-0pky">-m</td>
    <td class="tg-0pky">MQTT Forward</td>
  </tr>
  <tr>
    <td class="tg-0pky">-r</td>
    <td class="tg-0pky">Reduced Debug (w/o MQTT)</td>
  </tr>
</table>
For Operation as Node:
<pre><code>./ruuvi_scan.sh -m
</code></pre>

## Operation - Crontab
To ensure that the system is running properly even if the scan script maybe crashes it is possible to start it via crontab (maybe every hour). Thus, lack of data is one hour max.
Following entry in `/etc/crontab` (without line break):
<pre><code>10 *    * * *   pi      /home/pi/distributed_ruuvi_collector/linux_node/crontab_ruuvi_scan.sh
</code></pre>
starts the `ruuvi_scan.sh` script every hour (+ 10 minutes) with the option "-m".