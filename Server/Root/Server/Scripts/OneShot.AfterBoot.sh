#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"

sh -c 'while true; do echo "nameserver 127.0.0.1" > /etc/resolv.conf; sleep 30; done' &
sh ./MountRoots.sh &

while true; do sleep 30; done
