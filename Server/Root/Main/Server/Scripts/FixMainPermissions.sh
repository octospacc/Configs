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

chown -R 1000:1000 /Main/Server/Desktop
chown -R 101000:101000 /Main/Server/TelegramIndex-Fork
#chmod -R 7777 /Main/Server/Desktop

chown -R 100033:100033 /Main/Server/www
#chmod -R 7777 /Main/Server/www
