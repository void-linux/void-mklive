GITVER := $(shell git rev-parse --short HEAD)
VERSION = 0.22
SHIN    += $(shell find -type f -name '*.sh.in')
SCRIPTS += $(SHIN:.sh.in=.sh)
DATE=$(shell date "+%Y%m%d")

T_IMAGES=rpi{,2,3}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} usbarmory{,-musl}
T_ARCHS=i686 x86_64{,-musl} armv{6,7}l{,-musl}


ARCHS=$(shell echo $(T_ARCHS))
IMAGES=$(shell echo $(T_IMAGES))
ALL_ROOTFS=$(foreach arch,$(ARCHS),void-$(arch)-ROOTFS-$(DATE).tar.xz)

SUDO := sudo

%.sh: %.sh.in
	 sed -e "s|@@MKLIVE_VERSION@@|$(VERSION) $(GITVER)|g" $^ > $@
	 chmod +x $@

all: $(SCRIPTS)

clean:
	rm -v *.sh

images:
	echo $(IMAGES)

rootfs-all: $(ALL_ROOTFS)

rootfs-all-print:
	echo $(ALL_ROOTFS)

void-%-ROOTFS-$(DATE).tar.xz:
	$(SUDO) ./mkrootfs.sh $*

.PHONY: clean rootfs-all rootfs-all-print
