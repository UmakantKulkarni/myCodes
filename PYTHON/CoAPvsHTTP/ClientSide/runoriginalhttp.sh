#!/bin/sh
cd /home/umakant/IoT

ck=$(date +%s)
tc -s qdisc > Throughput/HL0D0_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:602 -i ens38 & ./run7 & sleep 605;
tc -s qdisc >> Throughput/HL0D0_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL0D0_${ck}
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem loss 1
tc -s qdisc > Throughput/HL1D0_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:602 -i ens38 & ./run7 & sleep 605;
tc -s qdisc >> Throughput/HL1D0_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL1D0_${ck}
tc qdisc del dev ens38 root netem loss 1
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem loss 2
tc -s qdisc > Throughput/HL2D0_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:602 -i ens38 & ./run7 & sleep 605;
tc -s qdisc >> Throughput/HL2D0_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL2D0_${ck}
tc qdisc del dev ens38 root netem loss 2
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 10ms
tc -s qdisc > Throughput/HL0D10_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:602 -i ens38 & ./run7 & sleep 605;
tc -s qdisc >> Throughput/HL0D10_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL0D10_${ck}
tc qdisc del dev ens38 root netem delay 10ms
sleep 10

ck=$(date +%s)
tc qdisc add dev ens38 root netem delay 50ms
tc -s qdisc > Throughput/HL0D50_${ck}.txt
tshark -w /tmp/ck${ck}.pcap -a duration:602 -i ens38 & ./run7 & sleep 605;
tc -s qdisc >> Throughput/HL0D50_${ck}.txt
cp /tmp/ck${ck}.pcap /home/umakant/IoT/Throughput/HL0D50_${ck}
tc qdisc del dev ens38 root netem delay 50ms
sleep 10
