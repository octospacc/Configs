#!/bin/sh
set -e
if [ "$(id -u)" != 0 ]; then
	echo "Must run as root"
	exit 1
fi

apt autoremove --purge
lxc-attach Debian2023 -- apt autoremove --purge

rm -rf /Main/Backup/*.old

rm -f /Main/Server/www/pixelfed_liminalgici/storage/logs/*.log

sh -c 'truncate -s 100M /var/lib/docker/containers/*/*-json.log'

docker exec -it pihole rm -f /var/log/pihole/pihole.log
docker restart pihole

docker system prune -f
