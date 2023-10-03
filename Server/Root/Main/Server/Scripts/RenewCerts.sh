#!/bin/sh
systemctl stop SocatIpProxies
#certbot renew
lxc-attach Debian2023 certbot renew
systemctl start SocatIpProxies
