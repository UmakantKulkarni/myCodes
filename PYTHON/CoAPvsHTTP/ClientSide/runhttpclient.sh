#!/bin/sh
#/sbin/ifconfig ens38 inet6 add 2001:470:8865:4001:192:168:146:128/64
#for i in {1..250}; do curl http://192.168.146.129:4040/Voltage ; sleep 0.00000002; done
#while true; do curl http://192.168.146.129:4040/Voltage ; sleep 0.00000000; done
#while true; do curl http://[2001:470:8865:4001:192:168:146:129]:6060/Voltage ; sleep 0.00000000; done
curl http://[2001:470:8865:4001:192:168:146:129]:6060/Voltage
ps aux | grep curl | awk '{print $2}' | xargs kill -9
