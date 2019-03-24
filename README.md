#### Unofficial fork of void-mklive

I created this fork of void-mklive because, as of this writing, certain 
features don't work in the official void-installer, such as Wi-Fi
and f2fs support on UEFI. f2fs is supported on UEFI systems by giving users
the option to mount the EFI system partition at /boot instead of /boot/efi.
See the section titled "EFI system partition mountpoints" for more info. 
I also plan on adding support for ZFS if the license permits it (ZFS is
under the CDDL, which is incompatible with the GPL, but it's available
in the void repositories, so perhaps the installer can support it). I 
also plan on adding support for refind in addition to grub, giving 
the users the option to install sway during the installation, and more!

#### Why refind instead of grub?

In my opinion, refind is better-suited for UEFI systems and is a lot easier 
to configure. refind is a much easier bootloader to work with (although
technically it's a boot manager).

#### EFI system partition mountpoints

One issue I ran into when originally trying to install void linux on my laptop
was that I couldn't get it to work with f2fs. After some research, I discovered
why f2fs failed to install: the official void installer mounts the EFI system 
partition (where EFI executables such as boot managers are stored) at 
/boot/efi. However, the kernel is installed in /boot. This means that if your
root partition is formatted as f2fs, then GRUB won't be able to locate the 
kernel image, since GRUB doesn't support f2fs. There are two workarounds. 
One is to create a partition at /boot formatted with some filesystem that GRUB
understands, in addition to the EFI sytem partition at /boot/efi. This works 
even with the official installer. However, the other solution is to just mount 
the EFI system partition at /boot. However, the official installer won't let 
you do this. So I've modified the installer to give you the option to mount
the EFI system partition at /boot.

## Can't you just install void in Legacy BIOS compatibility mode?

Not on my laptop at least. My storage device is an embedded SD card, and I
don't think I can boot an OS off of it in Legacy BIOS compatibility mode (I've
tried to install OSes in Legacy BIOS mode on my internal SD card many times, 
and it's never worked). So on my laptop, I only have the option of installing 
it in UEFI mode.

## Why is f2fs support so important anyway?

f2fs is optimized for flash-storage devices, and there's evidence that 
it can prolong the lifetime of flash cards and other flash-based storage
devices. Since many low-end laptops have internal SD cards for their primary 
storage, and since many of these laptops only support UEFI for booting off
of the internal SD card, it's really important to support f2fs on UEFI.

#### Wi-Fi changes

The original changes I made in my first PR were pretty hacky. But I intend to
get wi-fi working pretty soon, and I plan on making the wi-fi fixes less hacky.
