#!/bin/sh
cd /home/umakant
ip=$(ip -f inet -o addr show ens33|cut -d\  -f 7 | cut -d/ -f 1)
while [ 1 ]; do
	coapclient.py -o GET -p coap://$ip:5683/Voltage
	sleep 0.002
	fuser -n udp -k 5683
	ps aux | grep python | grep -v "grep python" | awk '{print $2}' | xargs kill -9
done
