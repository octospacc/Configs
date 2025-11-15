#!/bin/sh
set -e
if [ "$(id -u)" != 0 ]; then
	echo "Must run as root"
	exit 1
fi

lxc-attach Debian2023 -- systemctl stop Aggregodo

cd /Main/Server/Aggregodo
git stash
git pull
chmod -R 777 /Main/Server/Aggregodo

lxc-attach Debian2023 -- sudo -u tux bash -c "
set -e
cd /Main/Server/Aggregodo
npm install --force
npm run build
cd ./data
cp ./data.sqlite ./data.sqlite.bak
"

lxc-attach Debian2023 -- systemctl start Aggregodo
