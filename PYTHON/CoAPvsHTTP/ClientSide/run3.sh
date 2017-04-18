#!/bin/sh
fuser -n udp -k 5683
ps aux | grep python | grep -v "grep python" | awk '{print $2}' | xargs kill -9
fuser -n udp -k 6060
ps aux | grep http | grep -v "grep http" | awk '{print $2}' | xargs kill -9
ps aux | grep curl | awk '{print $2}' | xargs kill -9
