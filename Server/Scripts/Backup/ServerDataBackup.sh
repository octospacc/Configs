#!/bin/sh
# Make local backups of the data from the hosted services

. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

SimpleBackup() {
	mkdir -p "./$1"
	tar cvJSf "./$1/${RunDate}.tar.xz" "/Server/$1" && \
	cp "./$1/${RunDate}.tar.xz" "./$1/Latest.tar.xz"
}

# Wallabag
SimpleBackup "wallabag-data"
#Name="wallabag-data"
#mkdir -p "./${Name}"
#tar cvJSf "./${Name}/${Date}.tar.xz" "/Server/${Name}" && \
#cp "./${Name}/${Date}.tar.xz" "./${Name}/Latest.tar.xz"
#7z a -mmt1 -mx9 \
#	"./${Name}/${Date}.7z" /Server/wallabag-data && \
#	cp "./${Name}/${Date}.7z" "./${Name}/Latest.7z"

# FreshRSS
SimpleBackup "FreshRSS-data"
#Name="FreshRSS-data"
#mkdir -p "./${Name}"
#tar cvJSf "./${Name}/${Date}.tar.xz" "/Server/${Name}" && \
#cp "./${Name}/${Date}.tar.xz" "./${Name}/Latest.tar.xz"
#7z a -mmt1 -mx9 \
#	"./${Name}/${Date}.7z" /Server/FreshRSS/data && \
#	cp "./${Name}/${Date}.7z" "./${Name}/Latest.7z"
#7z a -mmt1 -mx9 \
#	"./FreshRSS-data/${Date}.7z" /media/Disk/Server/docker-base/volumes/775f882852d2ca0efacd0e92426d07a1257c6ffc65aa83ce0970969c95f0fefd/_data/www/freshrss/data && \
#	cp "./FreshRSS-data/${Date}.7z" ./FreshRSS-data/Latest.7z
#7z a -mx9 -mmt1 "./FreshRSS-data/$Date.7z" /Server/FreshRSS/data && cp "./FreshRSS-data/$Date.7z" ./FreshRSS-data/latest.7z

# GoToSocial
#Name="GoToSocial"
#mkdir -p "./${Name}"
#tar cvJSf "./${Name}/${Date}.tar.xz" /Server/GoToSocial.Home

# Misskey
#7z a -mx1 -mmt1 ./misskey-home.7z /Server/misskey-home
#zip -r ./misskey-home.zip /Server/misskey-home.virtual

#cd /media/Disk/Backup/Social-Notes-Articles-Backups
#git pull
#cd /Server/Bots/MastodonFeedHTML
#for Dir in @*@*.*
#do
#	cp -r $Dir /media/Disk/Backup/Social-Notes-Articles-Backups/$Dir
#	mv $Dir $Dir.old
#done
#cd /media/Disk/Backup/Social-Notes-Articles-Backups
#for Dir in @*@*.*
#do
#	cd $Dir
#	for File in *.html
#	do
#		7z a -mx9 -mmt1 "$File.7z" "$File"
#	done
#	rm *.html
#	cd ..
#done

date > "${BackupsBase}/Last.log"
