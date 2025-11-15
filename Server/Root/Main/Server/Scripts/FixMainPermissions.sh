#!/bin/sh

for Dir in \
	Public \
; do
	cd "/Main/${Dir}"
	chown -R root:root .
	chmod -R 7777 .
done
#Server \
#Backup \

#chown -R 1000:1000 /Main/Server/Desktop

for Dir in \
	Backup/SpaccCraft \
	Server/TelegramIndex-Fork \
	Server/Bots/RSS-to-Telegram-Bot-Fork \
; do chown -R 101000:101000 "/Main/${Dir}"
done

chown -R 100033:100033 /Main/Server/www
chmod -R 777 /Main/Server/www

chmod -R 777 /Main/Server/Bots
chmod -R 777 /Main/Server/Pignio
chmod -R 777 /Main/Server/WuppiMini
chmod -R 777 /Main/Server/SpaccBBS-NodeBB
chmod -R 777 /Main/Server/mpgram-web
chmod -R 777 /Main/Server/Sharkey/files
chmod -R 777 /Main/Server/Aggregodo # /data

chmod -R 777 /media/320GB/NintendoSwitchAlbum/

chown -R tux:tux /Main/Backup/
chown -R tux:tux /Main/Clouds/octt/
