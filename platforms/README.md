## mklive platforms

To allow for platform-specific customization (and platform-specific/generic
images all-in-one) on aarch64, `mklive.sh -P "platform1 platform2 ..."` can be
used. That will, in turn, source `platform1.sh` and `platform2.sh` from this
directory to do a few things:

1. add packages to the image
2. add menu entries in GRUB

### File format

```bash
# an optional pretty name
PLATFORM_NAME="Thinkpad X13s"
# any additional packages to add (bash array)
PLATFORM_PKGS=(x13s-base)
# any special kernel cmdline arguments
PLATFORM_CMDLINE="rd.driver.blacklist=qcom_q6v5_pas arm64.nopauth clk_ignore_unused pd_ignore_unused"
# device tree (path relative to /boot/dtbs/dtbs-$version/)
PLATFORM_DTB="qcom/sc8280xp-lenovo-thinkpad-x13s.dtb"
```
