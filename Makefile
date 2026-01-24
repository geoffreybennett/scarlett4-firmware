.PHONY: help install tar rpm deb arch clean

FIRMWARE_DIR := firmware
FIRMWARE_FILES := $(wildcard $(FIRMWARE_DIR)/*.bin)
LICENSE_FILES := $(wildcard LICENSE*)
VERSION := $(shell \
  git describe --abbrev=4 --dirty --always --tags 2>/dev/null | sed 's/-rc/~rc/g; s/-/./g' || \
  echo $${APP_VERSION:-Unknown} \
)
NAME := scarlett4-firmware
SPEC_FILE := $(NAME).spec
TAR_DIR := $(NAME)-$(VERSION)
TAR_FILE := $(TAR_DIR).tar.gz

help:
	@echo "Usage:"
	@echo "  make install - Install firmware files to /usr/lib/firmware/scarlett4"
	@echo "  make tar - Create a tarball of the firmware files and spec file"
	@echo "  make rpm - Build an RPM package from the tarball"
	@echo "  make deb - Build a deb package"
	@echo "  make arch - Generate PKGBUILD for Arch Linux"
	@echo "  make clean - Remove generated files"

install:
	install -d $(DESTDIR)/usr/lib/firmware/scarlett4
	install -m 644 $(FIRMWARE_FILES) $(DESTDIR)/usr/lib/firmware/scarlett4

tar: $(FIRMWARE_DIR) $(LICENSE_FILES)
	mkdir -p $(TAR_DIR)
	sed 's_VERSION$$_$(VERSION)_' < $(SPEC_FILE).template > $(TAR_DIR)/$(SPEC_FILE)
	cp -r $(FIRMWARE_DIR) $(LICENSE_FILES) debian Makefile $(TAR_DIR)/
	tar czf $(TAR_FILE) $(TAR_DIR)
	rm -rf $(TAR_DIR)

rpm: tar
	rpmbuild -ta $(TAR_FILE)

deb:
	mkdir -p deb-build/DEBIAN \
	         deb-build/usr/lib/firmware/scarlett4 \
	         deb-build/usr/share/doc/$(NAME)
	cp $(FIRMWARE_FILES) deb-build/usr/lib/firmware/scarlett4
	@echo "Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/" > deb-build/usr/share/doc/$(NAME)/copyright
	@echo "Source: https://github.com/geoffreybennett/$(NAME)" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "Upstream-Name: $(NAME)" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "Upstream-Contact: Geoffrey D. Bennett <g@b4.vu>" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "Files: *" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "Copyright: 2024-2025 Focusrite Audio Engineering Limited" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "License: Focusrite-Firmware" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "" >> deb-build/usr/share/doc/$(NAME)/copyright
	@echo "License: Focusrite-Firmware" >> deb-build/usr/share/doc/$(NAME)/copyright
	@sed 's/^$$/./' LICENSE.Focusrite | sed 's/^/ /' >> deb-build/usr/share/doc/$(NAME)/copyright
	sed "s/VERSION/$(VERSION)/g" debian/control > deb-build/DEBIAN/control
	dpkg-deb --root-owner-group --build deb-build $(NAME)_$(VERSION).deb
	rm -rf deb-build

arch:
	sed 's/VERSION/$(VERSION)/g' PKGBUILD.template > PKGBUILD

clean:
	rm -rf $(TAR_FILE) $(NAME)_$(VERSION).deb
