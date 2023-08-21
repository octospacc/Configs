#!/bin/sh
systemctl stop nginx
#cd /etc/letsencrypt/live/
#for Domain in *.octt.eu.org
#do
#	certbot certonly --standalone -d $Domain
#done
certbot renew
systemctl start nginx
