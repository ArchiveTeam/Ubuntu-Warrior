#!/bin/sh
reset
echo "=== Starting Warrior Download ==="
docker run -d -p 8001:8001 archiveteam/warrior-dockerfile &>/tmp/dockerid
reset
if [ ! "$(docker ps -a | grep archiveteam/warrior-dockerfile)" ] then
echo "Startup Failure! Unable to start the Docker Instance, Sleeping 30 Seconds
sleep 30
exit
fi
echo "================================="
echo "You can now login to the web interface at"
echo " http://127.0.0.1:8001"

