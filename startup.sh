#!/bin/sh
reset
echo "=== Starting Warrior Download ==="
docker run -d -p 8001:8001 archiveteam/warrior-dockerfile
reset
if [ ! "$(docker ps -a | grep archiveteam/warrior-dockerfile)" ]; then
echo "Startup Failure! Unable to start the Docker Instance, Sleeping 30 Seconds"
sleep 30
exit
fi
echo
echo "=== Archive Team Warrior ==="
echo
echo "The warrior has successfully started up."
echo
echo "To manage your warrior, open your web browser"
echo "and login to the web interface at"
echo " http://127.0.0.1:8001"
echo
sleep 120
while true; do
sleep 10
if [ ! "$(docker ps -a | grep archiveteam/warrior-dockerfile)" ]; then
echo "Docker Detected Instance has been turned OFF, Powering off!"
poweroff
fi
done
