GITVER := $(shell git rev-parse --short HEAD)
VERSION = 0.22
SHIN    += $(shell find -type f -name '*.sh.in')
SCRIPTS += $(SHIN:.sh.in=.sh)
DATE=$(shell date "+%Y%m%d")

T_PLATFORMS=rpi{,2,3}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} usbarmory{,-musl} GCP{,-musl}
T_ARCHS=i686 x86_64{,-musl} armv{6,7}l{,-musl} aarch64{,-musl}

ARCHS=$(shell echo $(T_ARCHS))
PLATFORMS=$(shell echo $(T_PLATFORMS))

ALL_ROOTFS=$(foreach arch,$(ARCHS),void-$(arch)-ROOTFS-$(DATE).tar.xz)
ALL_PLATFORMFS=$(foreach platform,$(PLATFORMS),void-$(platform)-PLATFORMFS-$(DATE).tar.xz)

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

void-%-ROOTFS-$(DATE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkrootfs.sh $*

void-%-PLATFORMFS-$(DATE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkplatformfs.sh $* void-$(shell ./lib.sh platform2arch $*)-ROOTFS-$(DATE).tar.xz

platformfs-all: $(ALL_PLATFORMFS)

platformfs-all-print:
	@echo $(ALL_PLATFORMFS) | sed "s: :\n:g"

.PHONY: clean rootfs-all-print platformfs-all-print
