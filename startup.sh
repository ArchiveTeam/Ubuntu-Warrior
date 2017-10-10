#!/bin/sh
reset
echo "=== Starting Warrior Download ==="
rm -f /root/docker_container_id.txt
docker run -d -p 8001:8001 --cidfile="/root/docker_container_id.txt" \
    archiveteam/warrior-dockerfile

reset
if [ ! "$(docker ps | grep archiveteam/warrior-dockerfile)" ]; then
echo "Startup Failure! Unable to start the Docker Instance, Sleeping 30 Seconds"
sleep 30
exit 1
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

CONTAINER_ID=`cat /root/docker_container_id.txt`

while true; do
sleep 10
if docker exec -it $CONTAINER_ID test -f /tmp/warrior_reboot_required; then
    echo "Detected warrior needing reboot. Rebooting!"
    reboot
elif docker exec -it $CONTAINER_ID test -f /tmp/warrior_poweroff_required; then
    echo "Detected warrior needing poweroff. Powering off!"
    poweroff
elif docker ps -f id=$CONTAINER_ID -f status=dead | grep $CONTAINER_ID; then
    echo "Docker container instance dead. Rebooting!"
    reboot
elif docker ps -f id=$CONTAINER_ID -f status=exited | grep $CONTAINER_ID; then
    echo "Docker container instance exited, Powering off!"
    poweroff
fi
done
