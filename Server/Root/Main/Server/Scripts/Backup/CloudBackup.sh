#!/bin/sh
# Upload a backup of the Local Cloud and of local services backups to other clouds

set -e
. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

GitPush(){
	Msg="Auto-Backup $(date) (${RunDate})"
	git add . && git commit -m "${Msg}" && git push
}

GitPullPushPath(){
	BackPath="$(pwd)"
	cd "$1" && git pull && GitPush
	cd "${BackPath}"
}

BackPathCrypt(){
	_BackPathCrypt "$1" "$2" "$3"
}

_BackPathCrypt(){
	Folder="$1"
	Key="$2"
	Ext="$([ -z "$3" ] && echo ".tar.xz" || echo "$3")"
	Split="$4"
	File="${Folder}${Ext}"
	cp -v "../${Folder}/Latest${Ext}" "./${File}" && \
	ccencryptNow "./${File}" "${Key}"
	#DirContext="${PWD}"
	#[ -n "${Split}" ] \
	#	&& mkdir -p "./${File}.cpt.split" \
	#	&& cd "./${File}.cpt.split" \
	#	&& rm * || true \
	#	&& split --bytes="${Split}" "../${File}.cpt" \
	#	&& rm "../${File}.cpt" \
	#;
	#cd "${DirContext}"
}

BackPathCryptSplit(){
	_BackPathCrypt "$1" "$2" "$3" 10M
	#...
}

ServerBackupLimited(){
	EchoExec cd ./Server-Backup-Limited
	#BackPathCrypt "Invidious-User" "${BackupKey_Git_Invidious}" ".7z"
	#BackPathCrypt "wallabag-data" "${BackupKey_Git_wallabag}"
	BackPathCrypt FreshRSS "${BackupKey_Git_FreshRSS}"
	#BackPathCrypt "FreshRSS-data" "${BackupKey_Git_FreshRSS}"
	#BackPathCrypt "shiori-data" "${BackupKey_Git_Shiori}"
	BackPathCrypt n8n-data "${BackupKey_Git_n8n}"
	BackPathCrypt script-server "${BackupKey_Git_scriptserver}"
	# "${BackupKey_Git_aria2}" ".7z"
	BackPathCrypt docker-mailserver "${BackupKey_Git_dockermailserver}"
	GitPush || true
	EchoExec cd ..
}

ArticlesBackupPrivate(){
	EchoExec cd ./Articles-Backup-Private
	EchoExec rm -rf ./shiori-data
	EchoExec cp -rp "../shiori-data/Latest.d" "./shiori-data"
	GitPush || true
	EchoExec cd ..
}

DoSpaccBbsBackup(){
	EchoExec cd ./SpaccBBS-Backup-phpBB-2023
	EchoExec rm -rf ./SpaccBBS || true
	EchoExec cp -rp ../SpaccBBS/Latest.d ./SpaccBBS
	EchoExec cp ../SpaccBBS/Db.Latest.sql.tar.xz ./Db.sql.tar.xz
	for File in \
		./Db.sql.tar.xz \
		./SpaccBBS/config.php \
		./SpaccBBS/arrowchat/includes/config.php \
	; do ccencryptNow "$File" "$BackupKey_Git_SpaccBBS"
	done
	GitPush || true
	EchoExec cd ..
}

DoSpaccCraftBackup(){
	McServer="SpaccCraft"
	McEdition="Beta-1.7.3"
	McGit="spacccraft-b1.7.3-backup4"
	DestPath="${BackupsBase}/${McGit}"
	if [ -d "${DestPath}" ]
	then
		cd "${BackupsBase}/${McServer}"
		rm -rf "${DestPath}/${McEdition}" || true
		cp ./*.sh "${DestPath}/" || true
		cp -r "./${McEdition}/Latest.d" "${DestPath}/${McEdition}"
		GitPullPushPath "${DestPath}" || true
	fi
}

ServerBackupLimited || true
ArticlesBackupPrivate || true
DoSpaccBbsBackup || true
DoSpaccCraftBackup || true
#GitPullPushPath "/Cloud/Repos/Personal-Game-Saves"
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
