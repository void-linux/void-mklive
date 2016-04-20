#!/bin/sh

TARGET="$1"
[ -n "$TARGET" ] && shift

: ${PLATFORMS:="beaglebone cubieboard2 odroid-u2 rpi rpi2 usbarmory x86_64 i686"}
DATE=$(date '+%Y%m%d')

for f in ${PLATFORMS} x ${PLATFORMS}; do
	if [ "$f" = "x" ]; then
		musl=1
		continue
	fi
	target=$f
	if [ -n "$musl" ]; then
		target=${f}-musl
	fi
	if [ "$target" = "i686-musl" ]; then
		# XXX no i686-musl repo yet
		continue
	fi
        if [ -z "$TARGET" -o "$TARGET" = "$target" ]; then
		./mkrootfs.sh $@ $target
	fi
done
