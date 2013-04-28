GITVER := $(shell git rev-parse HEAD)
VERSION = 0.11
PREFIX ?= /usr/local
SBINDIR ?= $(PREFIX)/sbin
SHAREDIR ?= $(PREFIX)/share
DRACUTMODDIR ?= $(PREFIX)/lib/dracut/modules.d/01vmklive

all:
	sed -e "s|@@MKLIVE_VERSION@@|$(VERSION) $(GITVER)|g" mklive.sh.in > mklive.sh

install: all
	install -d $(DESTDIR)$(SBINDIR)
	install -m755 mklive.sh $(DESTDIR)$(SBINDIR)/void-mklive
	install -m755 void-mkrootfs.sh $(DESTDIR)$(SBINDIR)/void-mkrootfs
	install -d $(DESTDIR)$(DRACUTMODDIR)
	install -m755 dracut/*.sh $(DESTDIR)$(DRACUTMODDIR)
	install -d $(DESTDIR)$(SHAREDIR)/void-mklive
	install -m644 grub/*.cfg* $(DESTDIR)$(SHAREDIR)/void-mklive
	install -m644 isolinux/*.cfg* $(DESTDIR)$(SHAREDIR)/void-mklive

clean:
	-rm -f mklive.sh

dist:
	@echo "Building distribution tarball for tag: v$(VERSION) ..."
	-@git archive --format=tar --prefix=void-mklive-$(VERSION)/ \
		v$(VERSION) | xz -9 > ~/void-mklive-$(VERSION).tar.xz

.PHONY: all clean install dist
