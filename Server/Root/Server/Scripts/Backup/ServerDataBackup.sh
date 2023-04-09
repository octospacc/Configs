#!/bin/sh
# Make local backups of the data from the hosted services

. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

SimpleBackup() {
	# $1: Folder
	# $2: Optional prefix relative to path in /Server
	mkdir -vp "./$1"
	#tar cvJSf "./$1/${RunDate}.tar.xz" "/Server/$2/$1" && \
	#cp "./$1/${RunDate}.tar.xz" "./$1/Latest.tar.xz"
	EchoExec rm -rf "./$1/Latest.d"
	EchoExec cp -rp "/Server/$2/$1" "./$1/Latest.d"
	EchoExec tar cJSf "./$1/${RunDate}.tar.xz" "./$1/Latest.d" && \
	cp -v "./$1/${RunDate}.tar.xz" "./$1/Latest.tar.xz"	
}

#SimpleBackup "wallabag-data"
SimpleBackup "FreshRSS-data"

SimpleBackup "shiori-data" "Shiori"
rm -v "./shiori-data/Latest.d/archive/*"

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

WriteLastLog
