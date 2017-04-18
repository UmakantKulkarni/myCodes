#!/bin/sh
cd /home/umakant
ip=$(ip -f inet -o addr show ens38|cut -d\  -f 7 | cut -d/ -f 1)
coapclient.py -o GET -p coap://$ip:5683/Voltage 3
