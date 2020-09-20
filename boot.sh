#!/bin/sh
CHECK_HOST=warriorhq.archiveteam.org
MIN_CHECK_INTERVAL=5
MAX_CHECK_INTERVAL=300
REPO_PREFIX=https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/
BRANCH=master

if [ -f /root/repo_prefix.txt ]; then
    REPO_PREFIX=`cat /root/repo_prefix.txt`
fi
if [ -f /root/branch.txt ]; then
    BRANCH=`cat /root/branch.txt`
fi
source /root/env.sh
reset

echo === Starting Archive Team Warrior ===
echo Checking Internet
while true; do
wget -q --spider https://$CHECK_HOST/

if [ $? -eq 0 ]; then
    echo "Online!"
    break
else
    SLEEP_TIME=$(($MIN_CHECK_INTERVAL + $RANDOM % $MAX_CHECK_INTERVAL))
    echo "Unable to access the Internet"
    echo "Trying $CHECK_HOST again in $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
fi
done

echo "Pulling Latest scripts"
if [ -f /root/startup.sh ]; then
    cp /root/startup.sh /root/startup.sh.bak
fi
while true; do
rm -f /root/startup.sh /root/startup.sh-new
wget -q ${REPO_PREFIX}${BRANCH}/startup.sh -O /root/startup.sh-new
if [ $? -eq 0 ]; then
    mv /root/startup.sh-new /root/startup.sh
    echo "Done!"
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
