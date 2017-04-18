#!/bin/sh
cd /home/umakant/IoT
ck=$(date +%s)
tc qdisc add dev ens38 root netem loss 0
tc -s qdisc > Chaitrali/CL0D0_${ck}.txt
sh -x run3.sh & sleep 3; tshark -w /tmp/ck${ck}.pcap -a duration:420 -ni any & sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL0D0_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Chaitrali/CL0D0_${ck}
tc qdisc del dev ens38 root netem loss 0
sleep 10
