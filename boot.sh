#!/bin/sh
reset
echo === Starting Archive Team Warrior ===
echo Checking Internet
while true; do
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online!"
    break
else
    echo "Unable to access the Internet"
    echo "Trying google.com again in 5 seconds"
    sleep 5
fi
done
echo "Pulling Latest scripts"
while true; do
wget -q https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/master/startup.sh -O /root/startup.sh
if [ $? -eq 0 ]; then
    echo "Done!"
    break
else
    echo "Unable to download the startup script"
    echo "Trying again in 5 seconds"
    sleep 5
fi
done

chmod +x /root/startup.sh
/root/startup.sh
