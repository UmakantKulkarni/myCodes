#!/bin/sh
/sbin/ifconfig ens38 inet6 add 2001:470:8865:4001:192:168:146:128/64
cd /home/umakant/IoT

ck=$(date +%s)
tc -s qdisc > Chaitrali/CL0D0_${ck}.txt
sh -x run3.sh & sleep 3; sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL0D0_${ck}.txt
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem loss 1
tc -s qdisc > Chaitrali/CL1D0_${ck}.txt
sh -x run3.sh & sleep 3; sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL1D0_${ck}.txt
tc qdisc del dev ens38 root netem loss 1
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem loss 2
tc -s qdisc > Chaitrali/CL2D0_${ck}.txt
sh -x run3.sh & sleep 3; sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL2D0_${ck}.txt
tc qdisc del dev ens38 root netem loss 2
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 10ms
tc -s qdisc > Chaitrali/CL0D10_${ck}.txt
sh -x run3.sh & sleep 3; sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL0D10_${ck}.txt
tc qdisc del dev ens38 root netem delay 10ms
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 50ms
tc -s qdisc > Chaitrali/CL0D50_${ck}.txt
sh -x run3.sh & sleep 3; sh -x run5.sh & sleep 420; sh -x run3.sh & sleep 1; echo -ne '\n';
tc -s qdisc >> Chaitrali/CL0D50_${ck}.txt
tc qdisc del dev ens38 root netem delay 50ms
sleep 10
