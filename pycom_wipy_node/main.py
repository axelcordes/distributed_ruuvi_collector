## RuuviNode
# Scan for ruuvi beacons and transmitts adv telegram
# via MQTT to Broker according HCIDump Raw format in linux
#
# parts of this code ar inspired by https://github.com/rroemhild/micropython-ruuvitag

import pycom
from network import WLAN
from network import Bluetooth
from mqtt import MQTTClient
import machine
import time
from ubinascii import hexlify


## Defines
#
#
wlan_ssid = "SSID"
wlan_pw = "PW"
mqtt_server = "192.168.30.58"
mqtt_station_id = "RN-Keller"
mqtt_topic = "ruuvis"
ble_scantime = 30
ble_pdu_header = "04 3E 21 02 01 03 01" ## for ruuvi
ble_manufacturer_id = '9904' ## for ruuvi
#ble_whitelist = (b'aa:bb:cc:dd:ee:21', b'aa:bb:cc:dd:ee:42',)
loop_time = 30 ## time in seconds between BLE scans
def settimeout(duration):
    pass
def hexlifyNone( object ):
    return None if object is None else hexlify( object ).decode("utf-8").upper()


## Init
#
#
pycom.heartbeat(False) ## disable heartbeat LED


## WLAN_Setup: Connect to IoT wlan
#
#
wlan = WLAN(mode=WLAN.STA) ## switch to mode: WLAN Station
wlan.connect(wlan_ssid, auth=(WLAN.WPA2, wlan_pw), timeout=5000)
while not wlan.isconnected():
    machine.idle()
print("WLAN connection succeeded!\n")


## MQTT_Setup: Setup MQTT connection
#
#
client = MQTTClient(mqtt_station_id, mqtt_server, port=1883)
client.settimeout = settimeout
client.connect()


## BLE_Setup: Setup Bluetooth
#
#
ble = Bluetooth()


## @fn ble_scan(timeout=10, whitelist=None)
# @Brief Scan for ADV Telegramms from specifi manufacturer
#
# @param timeout BLE scan time
# @param whitelist List with allowed MAC addresses
# @return beacons List with received adv packets
def ble_scan(timeout=10, whitelist=None):
  beacons = {}
  ble.start_scan(timeout)
  ## blue to indicate BLE activity
  pycom.rgbled(0x000005)
  while ble.isscanning():
    adv = ble.get_adv()
    if adv:
      ## get PAYLOAD
      payload = hexlifyNone(ble.resolve_adv_data(adv.data, Bluetooth.ADV_MANUFACTURER_DATA))
      if payload and payload[0:4] in (ble_manufacturer_id): # Manufactuer Filter
        ## Only take mac in whitelist
        mac = hexlify(adv.mac, ':').upper()
        #print(mac) # Debug
        if mac in beacons:
          continue
        elif whitelist is not None:
          if mac not in whitelist:
            continue

        beacons[mac] = adv
    else:
      time.sleep(0.050)

  pycom.rgbled(0x000000)  ## OFF
  return beacons

## @fn process_mqtt(beaconlist, publish_topic)
# @Brief Process BLE Advertising telegramms and forward data to mqtt broker
#
# @param beaconlist List with received adv frames
# @param publish_topi mqqt topic
def process_mqtt(beaconlist, publish_topic):
  pycom.rgbled(0x000500)  # Green
  for entry in beaconlist:
      ## get MAC
      mac = hexlifyNone( beaconlist[entry].mac )
      ## get adv frame
      ad_packet = hexlifyNone( beaconlist[entry].data )
      ad_length = int(ad_packet[6:8],16) + 4 ## length of complete ADC frame
      ad_packet = ad_packet[0:ad_length*2] ## truncate correct length
      ad_packet = ' '.join(ad_packet[i:i+2] for i in range(0, len(ad_packet), 2))  ## separate bytes with " "
      ## get rssi
      rssi = beaconlist[entry].rssi + 256

      # Enable 4 Debug
      #print(mac) # Debug
      #print(payload) # Debug
      #print(ad_packet) # Debug
      #print(rssi)

      ## send via MQTT
      ad_length = "%02X" %ad_length  ## convert to hex string
      rssi = "%02X" %rssi ## convert to hex string
      ble_mac = mac[10:12]+" "+mac[8:10]+" "+mac[6:8]+" "+mac[4:6]+" "+mac[2:4]+" "+mac[0:2]
      publish_msg = "> "+ble_pdu_header+" "+ble_mac+" "+ad_length+" "+ad_packet+" "+rssi
      client.publish(topic=publish_topic, msg=publish_msg)

  pycom.rgbled(0x000000)  ## OFF


## MAIN
# @Brief Mainloop
#
while True:
    beacons = ble_scan(ble_scantime)
    time.sleep(1)
    process_mqtt(beacons, mqtt_topic)
    time.sleep(1)
    pycom.rgbled(0x050000)  ## Red
    time.sleep(loop_time-2)
    pycom.rgbled(0x000000)  ## OFF


## CLEANUP (will be never reached)
#
#
client.disconnect()  # Disconnect MQTT Client
wlan.disconnect() # Disconnect from wlan
pycom.rgbled(0x000000)


#pycom.rgbled(0xFF0000)  # Red
#pycom.rgbled(0x00FF00)  # Green
#pycom.rgbled(0x0000FF)  # Blue
#pycom.rgbled(0x000000)  # OFF
