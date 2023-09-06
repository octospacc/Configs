#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

h=home/tux

SetScope Root
mkcd ./Root
	CpSufx etc/ diycron

	for f in \
		diycron ncshell OneShot.AfterBoot bittorrentd SocatIpProxies \
		Shiori ShioriFeed \
		CringeInoltro WinDog \
		TelegramIndex WebFileManager \
		SpaccCraft FreshRSS-actualize \
	; do
		CpItem "etc/systemd/system/${f}.service"
		CpItem "etc/systemd/system/${f}.timer"
	done

	for f in \
		WindowsServer2022 Windows7Earnapp1 \
	; do CpItem "etc/systemd/system/Vm${f}.service"
	done

	#CpItem etc/nginx/nginx.conf
	#CpSufx "etc/nginx/sites-available/*." conf old
	#CpItem etc/tor/torrc

	CpSufx "Main/Server/Scripts/*." sh
	CpSufx "Main/Server/Scripts/Backup/*." sh cfg
	CpSufx "Main/Server/Scripts/Interactive/*." sh
	#CpItem Main/Server/Scripts/OneShot.AfterBoot.sh
	#CpItem Main/Server/Scripts/RenewCerts.sh

	#CpItem Main/Server/Start/bittorrentd
	#CpItem Main/Transfers/aria2/Conf

	ScopePath=/var/lib/lxc/Debian2023/rootfs/
		CpItem etc/nginx/nginx.conf
		CpSufx "etc/nginx/sites-available/*." conf old
		CpItem etc/tor/torrc

		#for f in \
		#	SpaccBBS.conf SpaccCloud.conf XSpacc.conf admin.conf analytics.conf articles.conf feeds.conf root.conf \
		#; do CpItem "etc/nginx/sites-available/${f}"
		#done

	ScopePath=/var/lib/lxc/Ubuntu2023-SpaccCraft/rootfs/
		CpItem etc/systemd/system/SpaccCraft.service

cd ..

SetScope Home
mkcd ./Home
	#mkdir -vp ./.config
	#for p in \
	#	aria2
	#do
	#	cp -vrT /$h/.config/$p ./.config/$p
	#done
