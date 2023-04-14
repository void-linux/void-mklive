#!/bin/bash
xorg_base

PKGS+=("lxde" "lightdm" "gvfs-afc" "gvfs-mtp" "gvfs-smb" "udisks2" "firefox")
SERVICES+=("acpid" "dbus" "dhcpcd" "wpa_supplicant" "lightdm" "polkitd")
