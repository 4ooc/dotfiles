#!/bin/sh

localIp=$(ifconfig 2>&1 | grep -A3 wlan | awk '/inet/{print "    " $2}')
if [ -n "$localIp" ]; then
  echo "Current IP:"
  echo $localIp
fi
