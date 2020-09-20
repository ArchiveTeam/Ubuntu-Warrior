#!/bin/sh
reset
echo "=== Starting Warrior Download ==="
if [ -f /root/docker_container_id.txt ]; then
    CONTAINER_ID=`cat /root/docker_container_id.txt`
    docker start $CONTAINER_ID
else
    docker run -d -p 8001:8001 --cidfile="/root/docker_container_id.txt" \
        archiveteam/warrior-dockerfile
    CONTAINER_ID=`cat /root/docker_container_id.txt`

    # Allow reading network stats by non-root
    docker exec -it $CONTAINER_ID adduser warrior dip
fi

if [ ! "$(docker ps | grep archiveteam/warrior-dockerfile)" ]; then
echo "***** Startup Failure! ******"
echo "Unable to start the Docker Instance"
echo "Sleeping 30 seconds before retrying..."
sleep 30
exit 1
fi

CONTAINER_ID=`cat /root/docker_container_id.txt`

docker exec -it $CONTAINER_ID rm -f /tmp/warrior_reboot_required \
    /tmp/warrior_poweroff_required

echo "Warrior is updating Seesaw Kit."
echo "The web interface will be ready at http://127.0.0.1:8001 soon."
echo "Please wait..."

for i in `seq 60`; do
sleep 5
if docker top $CONTAINER_ID | grep run-warrior; then
    break
elif [ $i -eq 60 ]; then
    echo "***** Startup Failure! ******"
    echo "Seesaw Kit did not successfully boot up and update."
    echo "Sleeping 30 seconds before retrying..."
    sleep 30
    exit 1
fi
done

reset
echo
echo "=== Archive Team Warrior ==="
echo
echo "The warrior has successfully started up."
echo
echo "To manage your warrior, open your web browser"
echo "and login to the web interface at"
echo " http://127.0.0.1:8001"
echo
sleep 20

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
