#!/bin/sh

cd "$( dirname "$( realpath "$0" )" )"

cp -v /etc/diycron ./diycron
cp -v /Server/Scripts/Backup/*.sh ./Scripts/Backup/
cp -v /Server/Scripts/Backup/*.cfg ./Scripts/Backup/
# nginx was done manually
