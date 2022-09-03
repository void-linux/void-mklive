#!/bin/bash

echo "void ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-void
echo "Defaults:void !requiretty" >> /etc/sudoers.d/99-void
chmod 0440 /etc/sudoers.d/99-void
mv /etc/sudoers.d/{,10-}wheel

xbps-fetch -o /usr/bin/growpart https://raw.githubusercontent.com/canonical/cloud-utils/ubuntu/0.31-22-g37d4e32a-0ubuntu1/bin/growpart
chmod +x /usr/bin/growpart

xbps-install -Sy util-linux coreutils sed shinit
ln -s /etc/sv/shinit /var/service/

cat <<'EOF' > /etc/runit/core-services/10-resize-root.sh
#!/bin/sh
rpart=$(findmnt -r -o SOURCE -v -n /)
rnum=$(cat /sys/class/block/$(basename $rpart)/partition)

/usr/bin/growpart ${rpart%%$rnum} $rnum
resize2fs $rpart
EOF

passwd -dl void
passwd -dl root

rm -rf /var/cache/xbps

shutdown -P now
