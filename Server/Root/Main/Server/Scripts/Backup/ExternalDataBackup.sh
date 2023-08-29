#!/bin/sh
# Make local backups of our data from various third-party services

set -e
. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

# Invidious personal JSON dump
InvidiousPersonalJsonDump(){
	Name="Invidious-User"
	mkdir -vp "./${Name}"
	curl \
		"${Invidious_Backup_URL}/subscription_manager?action_takeout=1&format=json" \
		-H "${Invidious_Backup_Cookie}" \
	| 7z a -mmt1 -mx9 "./${Name}/${RunDate}.7z" -si && cp -v "./${Name}/${RunDate}.7z" "./${Name}/Latest.7z"
}

#InvidiousPersonalJsonDump
WriteLastLog
