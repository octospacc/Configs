#!/bin/sh
# Upload a backup of the Local Cloud and of local services backups to other clouds

. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

GitPush() {
	Msg="Auto-Backup $(date) (${RunDate})"
	git add . && git commit -m "${Msg}" && git push
}

GitPullPushPath() {
	BackPath="$(pwd)"
	cd "$1" && git pull && GitPush
	cd "${BackPath}"
}

BackPathCrypt() {
	Folder="$1"
	Key="$2"
	Ext="$([ -z "$3" ] && echo ".tar.xz" || echo "$3")"
	cp -v "../${Folder}/Latest${Ext}" "./${Folder}${Ext}" && \
	ccencryptNow "./${Folder}${Ext}" "${Key}"
}

cd ./Server-Backup-Limited
BackPathCrypt "Invidious-User" "${BackupKey_Git_Invidious}" ".7z"
#BackPathCrypt "wallabag-data" "${BackupKey_Git_wallabag}"
BackPathCrypt "FreshRSS-data" "${BackupKey_Git_FreshRSS}"
#BackPathCrypt "shiori-data" "${BackupKey_Git_Shiori}"
# "${BackupKey_Git_aria2}" ".7z"
GitPush
cd ..

cd ./Articles-Backup-Private
EchoExec rm -rf ./shiori-data
EchoExec cp -rp "../shiori-data/Latest.d" "./shiori-data"
GitPush
cd ..

#McServer="SpaccCraft"
#McEdition="Beta-1.7.3"
#cd "/Server/${McServer}/spacccraft-b1.7.3-backup4"
#cp ../*.sh ./
#cp -rT "${BackupsBase}/${McServer}/${McEdition}/Latest" "./${McEdition}"
#GitPush
#cd "${BackupsBase}"

GitPullPushPath "/Cloud/Repos/Personal-Game-Saves"
#GitPullPushPath "/media/Disk/Configs"

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

WriteLastLog
