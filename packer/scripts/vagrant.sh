#!/bin/bash

useradd -m -s /bin/bash vagrant

# Set up sudo
echo '%vagrant ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant
echo 'Defaults:vagrant !requiretty' >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

gpasswd -d vagrant wheel

sudo xbps-install -Sy wget

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install NFS for Vagrant
xbps-install -Sy nfs-utils

passwd -dl vagrant
passwd -dl void
passwd -dl root

rm -rf /var/cache/xbps

shutdown -P now
