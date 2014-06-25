## The Void Linux image/live/rootfs maker and installer

This repository contains utilities for Void Linux:

 * installer (The Void Linux el-cheapo installer for x86)
 * mklive    (The Void Linux live image maker for x86)

 * mkimage   (The Void Linux image maker for ARM platforms)
 * mkrootfs  (The Void Linux rootfs maker for ARM platforms)

#### Dependencies

 * xbps>=0.35
 * GNU bash
 * parted (for mkimage)
 * qemu-user-static binaries (for mkrootfs)

#### Usage

Type

    $ make

and then see the usage output:

    $ ./mklive.sh -h
    $ ./mkrootfs.sh -h
    $ ./mkimage.sh -h

#### Examples

Build an x86 live image with runit and keyboard set to 'fr':

    # ./mklive.sh -b base-system-runit -k fr

Build an x86 live image with systemd and some optional packages:

    # ./mklive.sh -p 'vim rtorrent'

See the usage output for more information :-)
