#!/bin/sh
CHECK_HOST=warriorhq.archiveteam.org
MIN_CHECK_INTERVAL=5
MAX_CHECK_INTERVAL=300
REPO_PREFIX=https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/
BRANCH=master

source /root/env.sh
if [ -f /root/repo_prefix.txt ]; then
    REPO_PREFIX=`cat /root/repo_prefix.txt`
fi
if [ -f /root/branch.txt ]; then
    BRANCH=`cat /root/branch.txt`
fi

if [ -f /root/splashes/at-splash-startup-640x400-32.fb ]; then
    cat /root/splashes/at-splash-startup-640x400-32.fb > /dev/fb0
else
    reset

    echo === Starting Archive Team Warrior ===
    echo Checking Internet
fi

while true; do
wget -q --spider https://$CHECK_HOST/

if [ $? -eq 0 ]; then
    if ! [ -f /root/splashes/at-splash-startup-640x400-32.fb ]; then
        echo "Online!"
    fi
    break
else
    SLEEP_TIME=$(($MIN_CHECK_INTERVAL + $RANDOM % $MAX_CHECK_INTERVAL))
    echo "Unable to access the Internet"
    echo "Trying $CHECK_HOST again in $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
fi
done

if ! [ -f /root/splashes/at-splash-startup-640x400-32.fb ]; then
    echo "Pulling Latest scripts"
fi

if [ -f /root/startup.sh ]; then
    cp /root/startup.sh /root/startup.sh.bak
fi
while true; do
rm -f /root/startup.sh /root/startup.sh-new
wget -q ${REPO_PREFIX}${BRANCH}/startup.sh -O /root/startup.sh-new
if [ $? -eq 0 ]; then
    mv /root/startup.sh-new /root/startup.sh
    if ! [ -f /root/splashes/at-splash-startup-640x400-32.fb ]; then
        echo "Done!"
    fi
    break
else
    SLEEP_TIME=$(($MIN_CHECK_INTERVAL + $RANDOM % $MAX_CHECK_INTERVAL))
    echo "Unable to download the startup script"
    echo "Trying again in $SLEEP_TIME seconds"
    sleep ${SLEEP_TIME}
fi
done

chmod +x /root/startup.sh
/root/startup.sh

SLEEP_TIME=$(($MIN_CHECK_INTERVAL + $RANDOM % $MAX_CHECK_INTERVAL))
echo ==== Startup Script Failed, Restarting in $SLEEP_TIME seconds! ====
sleep $SLEEP_TIME
