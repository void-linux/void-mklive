## The Void Linux image/live/rootfs maker and installer

This repository contains utilities for Void Linux:

 * installer (The Void Linux el-cheapo installer for x86)
 * mklive    (The Void Linux live image maker for x86)

 * mkimage   (The Void Linux image maker for ARM platforms)
 * mkrootfs  (The Void Linux rootfs maker for ARM platforms)

#### Dependencies

 * xbps>=0.45
 * qemu-user-static binaries (for mkrootfs)

#### Usage

Type

    $ make

and then see the usage output:

    $ ./mklive.sh -h
    $ ./mkrootfs.sh -h
    $ ./mkimage.sh -h

#### Examples

Build a native live image with runit and keyboard set to 'fr':

    # ./mklive.sh -k fr

Build an i686 (on x86\_64) live image with some additional packages:

    # ./mklive.sh -a i686 -p 'vim rtorrent'

Build an x86\_64 musl live image with packages stored in a local repository:

    # ./mklive.sh -a x86_64-musl -r /path/to/host/binpkgs

See the usage output for more information :-)
