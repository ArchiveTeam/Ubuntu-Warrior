#!/bin/sh
reset
echo "=== Starting Warrior Download ==="
docker run -d -p 8001:8001 archiveteam/warrior-dockerfile &>/tmp/dockerid
reset
echo "================================="
echo "You can now login to the web interface at
echo " http://127.0.0.1:8001"
while true; do

sleep 2

done
