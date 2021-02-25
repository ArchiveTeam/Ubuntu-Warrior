#!/bin/sh
reset
echo "=== Starting Warrior Download ==="

# Versions 3.0 and 3.1 of the VM image use a file at /root/docker_container_id.txt to keep track
# of the container ID for the Warrior image. If this file is detected, the user is migrated to
# the new Warrior container. The migration process consists of extracting the user configuration
# file from the old container and then deleting the old container, pruning Docker containers,
# networks, and images (the --volumes parameter is not supported on the Docker version in the
# 3.0 VM image), and deleting the /root/docker_container_id.txt file.
# https://docs.docker.com/engine/reference/commandline/system_prune/
if [ -f /root/docker_container_id.txt ]; then
    echo "A new, upgraded Warrior capable of running more projects is available and will now be installed..."
    CONTAINER_ID=`cat /root/docker_container_id.txt`
    echo "Backing up the user configuration..."
    docker cp $CONTAINER_ID:/home/warrior/projects/config.json /root/config.json
    echo "Cleaning up the old version..."
    docker rm $CONTAINER_ID
    docker system prune -a -f
    rm /root/docker_container_id.txt
    echo "Now ready to install the new Warrior and automatic updater!"
fi

# Create a blank configuration file if none exists, otherwise do nothing
touch /root/config.json # https://unix.stackexchange.com/a/343558

# Make sure the container has access to the config file
chmod 777 /root/config.json

# If a container named watchtower does not exist, create and configure it.
# Watchtower is configured to check for updates every hour, and to delete outdated images.
# https://stackoverflow.com/a/50667460
if [ ! "$(docker ps -a --format {{.Names}} | grep watchtower)" ]; then
    echo "Please wait while the automatic updater is prepared..."
    docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --interval 3600
else
    docker start watchtower
fi

# If a container named warrior does not exist, create and configure it.
# Previous versions of startup.sh did not name containers.
# Additionally, the /root/config.json file is mounted inside the Docker container at
# /home/warrior/projects/config.json, allowing user configuration to be persisted across
# container deletions and Watchtower updates.
# https://stackoverflow.com/a/50667460
if [ ! "$(docker ps -a --format {{.Names}} | grep warrior)" ]; then
    echo "Please wait while the Warrior is downloaded and started..."
    echo "This may take a few minutes..."
    # Mount the user configuration from the host container
    # https://stackoverflow.com/a/54787364, https://docs.docker.com/storage/bind-mounts
    docker run -d -p 8001:8001 --name warrior -v /root/config.json:/home/warrior/projects/config.json atdr.meo.ws/archiveteam/warrior-dockerfile
    # Allow reading network stats by non-root
    docker exec -it warrior adduser warrior dip
else
    docker start warrior
fi

if [ ! "$(docker ps -a --format {{.Names}} | grep warrior)" ]; then
echo "***** Startup Failure! ******"
echo "Unable to start the Docker Instance"
echo "Sleeping 30 seconds before retrying..."
sleep 30
exit 1
fi

docker exec -it warrior rm -f /tmp/warrior_reboot_required \
    /tmp/warrior_poweroff_required

echo "Warrior is updating Seesaw Kit."
echo "The web interface will be ready at http://127.0.0.1:8001 soon."
echo "Please wait..."

for i in `seq 60`; do
sleep 5
if docker top warrior | grep run-warrior; then
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
echo "  http://127.0.0.1:8001"
echo
echo "Advanced info:"
echo "  These IP addresses are bound to eth0:"
ip addr show dev eth0 | awk '{if (match($1, "inet6?") != 0) print "  > "$2}'
echo
sleep 20

while true; do
sleep 10
if docker exec -it warrior test -f /tmp/warrior_reboot_required; then
    echo "Detected warrior needing reboot. Rebooting!"
    reboot
elif docker exec -it warrior test -f /tmp/warrior_poweroff_required; then
    echo "Detected warrior needing poweroff. Powering off!"
    poweroff
elif docker ps -f name=warrior -f status=dead | grep warrior; then
    echo "Docker container instance dead. Rebooting!"
    reboot
elif docker ps -f name=warrior -f status=exited | grep warrior; then
    sleep 5 # Prevent a Watchtower update from shutting down the system
    if docker ps -f name=warrior -f status=exited | grep warrior; then
        echo "Docker container instance exited, Powering off!"
        poweroff
    fi
fi
done
