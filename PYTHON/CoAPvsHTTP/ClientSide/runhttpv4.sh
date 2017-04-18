#!/bin/sh
cd /home/umakant/IoT
ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 50ms
tc -s qdisc > Throughput/HL0D50_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:420 -i ens38 & ./run7 & sleep 420;
tc -s qdisc >> Throughput/HL0D50_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL0D50_${ck}
tc qdisc del dev ens38 root netem delay 50ms
sleep 10
