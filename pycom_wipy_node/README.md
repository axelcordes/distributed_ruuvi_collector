# Node (PyCOM WiPy 3.0)
The PyCom WiPY device features a BLE and WiFi interface which could be used for the purposes of a BLE scanner. However, since the MQTT message format in this project have to look like the "hcidump" raw data format, every received ruuvi advertising telegram has to be reformatted. To make sure this process is not overloading the processor while receiving and filtering BLE advertising telegrams, the code scans for telegrams for a specific time and than process the received telegrams afterwords. 

## Installation
Configure the WiFi and MQTT settings pursuant your network setup in: "main.py" and install the files on the device according the documentation of the manufacturer.

## Operation
If the code is installed properly, the device immediately connects to the Wifi network and scans for ruuvi beacons after start up. The three states are indicated by the led:
<table class="tg">
  <tr>
    <th class="tg-0pky">Color</th>
    <th class="tg-0pky">Description</th>
  </tr>
  <tr>
    <td class="tg-0pky">Blue</td>
    <td class="tg-0pky">BLE Scanning</td>
  </tr>
  <tr>
    <td class="tg-0pky">Green</td>
    <td class="tg-0pky">MQTT Transmission</td>
  </tr>
    <tr>
    <td class="tg-0pky">Red</td>
    <td class="tg-0pky">Pause</td>
  </tr>
</table>