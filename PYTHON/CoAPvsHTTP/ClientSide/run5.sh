#!/bin/sh
cd /home/umakant
ip="2001:470:8865:4001:192:168:146:129"
coapclient.py -o GET -p coap://[$ip]:5683/Voltage 420
