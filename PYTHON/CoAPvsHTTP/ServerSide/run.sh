#!/bin/sh
/sbin/ifconfig ens38 inet6 add 2001:470:8865:4001:192:168:146:129/64
cd /home/umakant/IoT
sh -x run3.sh & sleep 3; sh -x runserver.sh & sleep 72000; sh -x run3.sh & sleep 1; echo -ne '\n';
#sh -x run3.sh & sleep 3; python httpserverv4.py & sleep 72000; sh -x run3.sh & sleep 1; echo -ne '\n';
