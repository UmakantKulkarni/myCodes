#!/bin/sh
fuser -n udp -k 5683
ps aux | grep python | grep -v "grep python" | awk '{print $2}' | xargs kill -9
fuser -n udp -k 6060
fuser -n udp -k 4040
ps aux | grep python | grep -v "grep python" | awk '{print $2}' | xargs kill -9
