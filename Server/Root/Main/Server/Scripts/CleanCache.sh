#!/bin/sh
#set -e
if [ "$(id -u)" != 0 ]; then
	echo "Must run as root"
	exit 1
fi

apt autoremove --purge -y
apt clean -y
rm -rf /var/lib/apt/lists/*

lxc-attach Debian2023 -- apt autoremove --purge -y
lxc-attach Debian2023 -- apt clean -y
lxc-attach Debian2023 -- rm -rf /var/lib/apt/lists/*

rm -rf /Main/Backup/*.old

rm -f /Main/Server/www/pixelfed_liminalgici/storage/logs/*.log

sh -c 'truncate -s 100M /var/lib/docker/containers/*/*-json.log'

docker exec -it pihole rm -f /var/log/pihole/pihole.log
docker restart pihole

docker system prune -f
