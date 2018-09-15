# distributed_ruuvi_collector
Distributed BLE scanner for collecting ruuvi beacon telegrams.

## Detailled description 
by end of week 37 2018.

## Brief Description
Purpose of the system is to cover a bigger flat or house with several scanning devices (linux or pycom microcontroller) which record BLE telegrams from ruuvi beacons and send this data to a central computer (in my case a raspi).  There a slightly modificated version of the Ruuvi collector (https://github.com/Scrin/RuuviCollector) in combination with InfluxDB and grafana should be used to store analyze and plot the data.

For doing this, the idea is to change the imput source of the ruuvi collector from hcidump to mqtt. Al the scanner than sends the received data in the raw data format of hcidump. Thus, no further changed to the existing ruuvi collector should be necessary.

The present folder (linux and pycom) just storing beta source code. The idea of using the pycom board is, not only to receive BLE telegrams, filter for ruuvi manufacturer id and sending the telegrams via mqtt but also use the Pysense header board and sends the data from the sensors on it as an own telegram which looks like the ruuvi ble telegram style. Thus, the data could also be processed with the existing ruuvi collector (https://github.com/Scrin/RuuviCollector).