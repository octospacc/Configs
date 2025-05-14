#!/bin/sh
set -e
if [ "$(id -u)" != 0 ]; then
	echo "Must run as root"
	exit 1
fi

docker exec -it pihole rm -f /var/log/pihole/pihole.log
docker restart pihole

docker system prune -f
