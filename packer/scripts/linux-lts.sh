#!/bin/sh

df -h
rm -rf /var/cache/xbps/
df -h

echo 'ignorepkg=linux' > /etc/xbps.d/90-ignore-linux.conf
xbps-remove -Ry linux
rm -fv /boot/"*$(uname -r)*"
xbps-install -y linux-lts
