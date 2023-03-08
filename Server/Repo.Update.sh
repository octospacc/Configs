#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
cd ./Root

cp -v /etc/diycron ./etc/diycron

cp -v \
	/etc/systemd/system/diycron.service \
	./etc/systemd/system/

cp -v \
	/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/*.old \
	./etc/nginx/sites-available/

cp -v \
	/Server/Scripts/Backup/*.sh /Server/Scripts/Backup/*.cfg \
	./Server/Scripts/Backup/
