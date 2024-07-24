#!/bin/bash

echo "void ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-void
echo "Defaults:void !requiretty" >> /etc/sudoers.d/99-void
chmod 0440 /etc/sudoers.d/99-void
mv /etc/sudoers.d/{,10-}wheel

xbps-install -Sy util-linux coreutils sed shinit cloud-guest-utils
ln -s /etc/sv/shinit /var/service/

sed -i -e 's/#ENABLE/ENABLE/' /etc/default/growpart

passwd -dl void
passwd -dl root

rm -rf /var/cache/xbps
rm -f /etc/ssh/ssh_host*

shutdown -P now
