#!/bin/sh

NumPackets="$(tshark -r http2.pcapng -Y 'http' | wc -l)"
echo ${NumPackets}
StartTime="$(tshark -r http2.pcapng -Y 'http' | sed -n '1p' | awk  '{print $2}')"
echo ${StartTime}
EndTime="$(tshark -r http2.pcapng -Y 'http' | sed -n '1000p' | awk  '{print $2}')"
echo ${EndTime}
Time="$(echo "$EndTime $StartTime" | awk '{print $1-$2}')"
echo ${Time}
data=0
length=0
counter=1
while [ $counter -le $NumPackets ]
  do
	length="$(tshark -r http2.pcapng -Y 'http' | sed -n '/$i p' | awk  '{print $7}')"   	
	data="$(echo "$data $length" | awk '{print $1+$2}')"
done
echo ${data}
