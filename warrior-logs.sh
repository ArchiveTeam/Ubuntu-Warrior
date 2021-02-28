#!/bin/sh

echo "Warrior logs will appear here shortly..."

if [ ! "$(docker ps --format {{.Names}} | grep warrior)" ]; then
  sleep 5
else
    reset
    echo "=== Warrior Logs ==="
    docker logs warrior --since 10s --details --follow
fi
