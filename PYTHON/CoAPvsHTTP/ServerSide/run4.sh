#!/bin/sh
while true; do sh -x runserver.sh & fuser -n udp -k 5683 ; sleep 0.001; done

