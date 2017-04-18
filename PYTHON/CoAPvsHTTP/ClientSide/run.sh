#!/bin/sh
/sbin/ifconfig ens38 inet6 add 2001:470:8865:4001:192:168:146:128/64
cd /home/umakant/IoT
ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 50ms
tc -s qdisc > Throughput/CL0D50_${ck}.txt
sh -x run3.sh & sleep 3; tshark -w /tmp/ck${ck}.pcap -a duration:420 -i ens38 & sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Throughput/CL0D50_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/CL0D50_${ck}
tc qdisc del dev ens38 root netem delay 50ms
sleep 10
