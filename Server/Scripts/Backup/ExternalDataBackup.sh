#!/bin/sh
# Make local backups of our data from various third-party services

. "$(dirname "$(realpath "$0")")/BackupGlobals.cfg"

# Invidious personal JSON dump
Name="Invidious-User"
mkdir -p "./${Name}"
curl \
	"${Invidious_Backup_URL}/subscription_manager?action_takeout=1&format=json" \
	-H "${Invidious_Backup_Cookie}" \
	| 7z a -mmt1 -mx9 "./${Name}/${RunDate}.7z" -si && cp "./${Name}/${RunDate}.7z" "./${Name}/Latest.7z"

WriteLastLog
