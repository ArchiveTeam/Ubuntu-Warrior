#!/bin/sh

echo "Watchtower (Automatic Updater) logs will appear here shortly..."

if [ ! "$(docker ps --format {{.Names}} | grep watchtower)" ]; then
  sleep 5
else
    reset
    echo "=== Watchtower (Automatic Updater) Logs ==="
    docker logs watchtower --since 10s --details --follow
fi
