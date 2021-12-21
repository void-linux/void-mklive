#!/bin/bash

# Enable Lighdm 
ln -s /etc/sv/dbus /var/service/dbus
ln -s /etc/sv/lightdm /var/service/lightdm

#Enable wpa_supplicant 
ln -s /etc/runit/sv/wpa_supplicant/run/runit/service

# Enable Fish as default shell 
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/bin/fish

