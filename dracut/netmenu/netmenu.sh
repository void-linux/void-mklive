#!/bin/sh

dialog --colors --keep-tite --no-shadow --no-mouse \
       --backtitle "\Zb\Z7Void Linux installation -- http://www.voidlinux.eu/\Zn" \
       --cancel-label "Reboot" --aspect 20 \
       --menu "Select an Action:" 10 50 2 \
       "Install" "Run void-installer" \
       "Shell" "Run dash" \
       2>/tmp/netmenu.action

if ! $? ; then
    reboot -f
fi

case $(cat /tmp/netmenu.action) in
    "Install") /usr/bin/void-installer ; exec sh ;;
    "Shell") exec sh ;;
esac
