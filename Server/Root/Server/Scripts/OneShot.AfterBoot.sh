#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"

sh ./MountRoots.sh &

while true; do sleep 30; done
