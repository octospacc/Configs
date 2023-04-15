#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

h=home/pi

mkcd ./Root
	mkdir -vp ./etc
	for p in \
		diycron
	do
		cp -v /etc/$p ./etc/$p
	done

	mkdir -vp ./etc/systemd/system
	cp -v \
		/etc/systemd/system/diycron.service \
		./etc/systemd/system/

	mkdir -vp ./etc/nginx/sites-available
	cp -v \
		/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/*.old \
		./etc/nginx/sites-available/

	mkdir -vp ./Server/Scripts/Backup
	cp -v \
		/Server/Scripts/Backup/*.sh /Server/Scripts/Backup/*.cfg \
		./Server/Scripts/Backup/

	mkdir -vp ./Server/Start
	cp -v /Server/Start/bittorrentd ./Server/Start/

	cpdir Transfers/aria2/Conf

cd ..

mkcd ./Home
	#mkdir -vp ./.config
	#for p in \
	#	aria2
	#do
	#	cp -vrT /$h/.config/$p ./.config/$p
	#done
