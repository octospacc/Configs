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
	CpSufx "Server/Scripts/Backup/*." sh cfg
	CpItem Server/Scripts/OneShot.AfterBoot.sh

	CpItem Server/Start/bittorrentd
	CpItem Transfers/aria2/Conf

cd ..

SetScope Home
mkcd ./Home
	#mkdir -vp ./.config
	#for p in \
	#	aria2
	#do
	#	cp -vrT /$h/.config/$p ./.config/$p
	#done
