#!/bin/sh
# Upload a backup of the Local Cloud and of local services backups to other clouds

. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

GitPush() {
	git add .
	git commit -m "Auto-Backup $(date) (${RunDate})"
	git push
}

cd ./Server-Backup-Limited
Item="Invidious-User" && cp "../${Item}/Latest.7z" "./${Item}.7z" && ccencryptNow "./${Item}.7z" "${BackupKey_Git_Invidious}"
Item="wallabag-data" && cp "../${Item}/Latest.tar.xz" "./${Item}.tar.xz" && ccencryptNow "./${Item}.tar.xz" "${BackupKey_Git_wallabag}"
Item="FreshRSS-data" && cp "../${Item}/Latest.tar.xz" "./${Item}.tar.xz" && ccencryptNow "./${Item}.tar.xz" "${BackupKey_Git_FreshRSS}"
GitPush
cd ..

#CloudDir="/home/octo/Cloud"
#cd "$CloudDir"

#TmpDir="/media/Disk/tmp/LocalToCloudBackup"
#mkdir "$TmpDir"

#find . -type f -exec ""$ScriptDir"/LocalToCloudBackup.Job" {} \;
#find . -type f -exec COMMAND 7z a -mx9 -mmt1 -p"$Password" "arc/"$i".7z" "$i" {} \;

#rclone sync -v "$CloudDir" "MEGA-octo-tutamail.com-Crypto":
#rclone sync -v "$CloudDir" "Dropbox-Union-20220407-Crypto":
#rclone sync -v "$CloudDir" "Box-Union-20220407-Crypto":
#rclone copy arc "mega octo":Backup/LocalCloud

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
#GitPush

date > "${BackupsBase}/Last.log"
