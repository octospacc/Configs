#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"
. ../Lib.sh

h=home/tux

SetScope Root
mkcd ./Root
	CpSufx etc/ diycron diycron.zx.mjs

	for f in \
		diycron BackupAll \
		ncshell OneShot.AfterBoot SocatIpProxies \
		CringeInoltro SpaccCraft \
	; do
		CpItem "etc/systemd/system/${f}.service"
		CpItem "etc/systemd/system/${f}.timer"
	done

	#CpSufx "Main/Server/VMs/*." sh
	for f in \
		WindowsServer2022 Windows7Earnapp1 Lubuntu2022NonProxied \
	; do
		CpItem "Main/Server/VMs/${f}.sh"
		CpItem "etc/systemd/system/Vm${f}.service"
	done

	CpSufx "Main/Server/Scripts/*." sh mjs
	CpSufx "Main/Server/Scripts/Backup/*." sh cfg
	CpItem Main/Server/Scripts/Interactive
	#CpItem Main/Server/Scripts/OneShot.AfterBoot.sh
	#CpItem Main/Server/Scripts/RenewCerts.sh

	CpItem Main/Server/Start/aria2c
	CpItem Main/Transfers/aria2/Conf

	ScopePath=/var/lib/lxc/Debian2023/rootfs/
		CpItem etc/nginx/nginx.conf
		CpSufx "etc/nginx/sites-available/*." conf old
		CpItem etc/tor/torrc
		for f in \
			matterbridge pixelfed_liminalgici FreshRSS-actualize \
			Shiori ShioriFeed \
			RssToTelegramBot WinDog \
			TelegramIndex WebFileManager WuppiMini \
		; do
			CpItem "etc/systemd/system/${f}.service"
			CpItem "etc/systemd/system/${f}.timer"
		done

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
