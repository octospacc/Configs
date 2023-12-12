#!/bin/sh

systemctl stop SocatIpProxies
certbot renew
systemctl start SocatIpProxies

lxc-attach Debian2023 -- /bin/sh -c "
systemctl stop nginx;
certbot renew;
systemctl start nginx;
"
