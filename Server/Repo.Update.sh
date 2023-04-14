#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

h=home/pi

mkcd ./Root
	for p in \
		diycron
	do
		cp -v /etc/$p ./etc/$p
	done

	cp -v \
		/etc/systemd/system/diycron.service \
		./etc/systemd/system/

	cp -v \
		/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/*.old \
		./etc/nginx/sites-available/

	cp -v \
		/Server/Scripts/Backup/*.sh /Server/Scripts/Backup/*.cfg \
		./Server/Scripts/Backup/

cd ..

mkcd ./Home
	mkdir -vp ./.config
	for p in \
		aria2
	do
		cp -vrT /$h/.config/$p ./.config/$p
	done
