#!/bin/sh
MEMDISK=$(memdiskfind)
if [ "$MEMDISK" ]; then
	modprobe phram phram=memdisk,$MEMDISK
	modprobe mtdblock
	printf 'KERNEL=="mtdblock0", RUN+="/sbin/initqueue --settled --onetime --unique /sbin/dmsquash-live-root /dev/mtdblock0"\n' >> /etc/udev/rules.d/99-live-squash.rules
fi
