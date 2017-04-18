#!/bin/sh
cd /home/umakant/IoT
tshark -w /tmp/ck1.pcap -a duration:420 -i ens38 & ./run7 & sleep 420;
