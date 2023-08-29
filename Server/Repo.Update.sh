#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

h=home/pi

SetScope Root
mkcd ./Root
	CpSufx etc/ diycron

	for f in \
		diycron ncshell OneShot.AfterBoot bittorrentd \
		Shiori ShioriFeed \
		CringeInoltro WinDog \
		TelegramIndex WebFileManager \
		SpaccCraft
	do
		cpfile "etc/systemd/system/$f.service"
	done

	CpItem etc/nginx/nginx.conf
	CpSufx "etc/nginx/sites-available/*." conf old
	CpItem etc/tor/torrc
	CpSufx "Main/Server/Scripts/Backup/*." sh cfg
	CpSufx "Main/Server/Scripts/Interactive/*." sh
	CpItem Main/Server/Scripts/OneShot.AfterBoot.sh
	CpItem Main/Server/Scripts/RenewCerts.sh

	CpItem Main/Server/Start/bittorrentd
	CpItem Main/Transfers/aria2/Conf

cd ..

SetScope Home
mkcd ./Home
	#mkdir -vp ./.config
	#for p in \
	#	aria2
	#do
	#	cp -vrT /$h/.config/$p ./.config/$p
	#done
