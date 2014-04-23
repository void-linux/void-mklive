## The Void Linux image/live/rootfs maker and installer

This repository contains utilities for Void Linux:

 * installer (The Void Linux el-cheapo installer for x86)
 * mklive    (The Void Linux live image maker for x86)

 * mkimage   (The Void Linux image maker for ARM platforms)
 * mkrootfs  (The Void Linux rootfs maker for ARM platforms)

#### Dependencies

 * xbps>=0.35
 * GNU bash
 * syslinux (to generate the PC-BIOS bootloader)
 * dosfstools (to generate the EFI bootloader)
 * xorriso (to generate the ISO image)
 * squashfs-tools (to generate the squashed rootfs)
 * parted (to generate image)
 * qemu-user-static binaries (to generate foreign rootfs)

#### Usage

Type

    $ make

and then see the usage output:

    $ ./mklive.sh -h
    $ ./mkrootfs.sh -h
    $ ./mkimage.sh -h
