#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
cd ./Root

cp -v /etc/diycron ./etc/diycron
# nginx was done manually

cp -v /Server/Scripts/Backup/*.sh ./Server/Scripts/Backup/
cp -v /Server/Scripts/Backup/*.cfg ./Server/Scripts/Backup/
