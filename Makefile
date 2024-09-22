# Directory variables.
SRCROOT=$(PWD)
OUTDIR=$(SRCROOT)/out
SRCDATADIR=$(SRCROOT)/data
DESTDIR=
PREFIX=/usr/local
SYSCONFDIR=/etc
BINDIR=$(DESTDIR)$(PREFIX)/bin
LIBEXECDIR=$(DESTDIR)$(PREFIX)/libexec
SYSTEMDUNITDIR=$(DESTDIR)$(SYSCONFDIR)/systemd/system
TMPFILESDIR=$(DESTDIR)$(SYSCONFDIR)/tmpfiles.d
SYSUSERSDIR=$(DESTDIR)$(SYSCONFDIR)/sysusers.d

# File wildcards.
SYSTEMDUNITS=*.service
TMPFILESDCONFIGS=*.tmpfiles
SYSUSERSDCONFIGS=*.sysusers

# Program suffix.
PROGPREFIX=aosc-portal-

# Command variables.
INSTALL_PROG=install -Dvm755
INSTALL_FILE=install -Dvm644

.PHONY: paste-server make-news-index

all: paste-server make-news-index

paste-server:
	mkdir -pv $(OUTDIR)
	cd $(SRCROOT)/paste-server && \
		go build -o $(OUTDIR)/$(PROGPREFIX)paste-server

make-news-index:
	mkdir -pv $(OUTDIR)
	cd $(SRCROOT)/make-news-index && \
		go build -o $(OUTDIR)/$(PROGPREFIX)make-news-index

install: install-paste-server install-make-news-index install-systemd install-post

install-paste-server:
	$(INSTALL_PROG) $(OUTDIR)/$(PROGPREFIX)paste-server \
		$(LIBEXECDIR)/$(PROGPREFIX)paste-server/$(PROGPREFIX)paste-server
	$(INSTALL_FILE) $(SRCDATADIR)/paste-server-config.yaml \
		$(LIBEXECDIR)/$(PROGPREFIX)paste-server/config.yaml

install-make-news-index:
	$(INSTALL_PROG) $(OUTDIR)/$(PROGPREFIX)make-news-index \
		$(BINDIR)/$(PROGPREFIX)make-news-index

install-systemd:
	# Installing systemd files.
	cd $(SRCDATADIR) && \
	for i in $(SYSTEMDUNITS); do \
		$(INSTALL_FILE) $$i \
			$(SYSTEMDUNITDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@LIBEXECDIR@|$(LIBEXECDIR)|g" \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(SYSTEMDUNITDIR)/$(PROGPREFIX)$$i; \
	done && \
	for i in $(TMPFILESDCONFIGS); do \
		$(INSTALL_FILE) $$i \
			$(TMPFILESDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(TMPFILESDIR)/$(PROGPREFIX)$$i; \
	done && \
	for i in $(SYSUSERSDCONFIGS); do \
		$(INSTALL_FILE) $$i \
                        $(SYSUSERSDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@LIBEXECDIR@|$(LIBEXECDIR)|g" \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(SYSUSERSDIR)/$(PROGPREFIX)$$i; \
	done

# FIXME: Make this more elegant.
install-post: install-systemd
	mv -v $(TMPFILESDIR)/$(PROGPREFIX)paste-server.tmpfiles \
		$(TMPFILESDIR)/$(PROGPREFIX)paste-server.conf
	mv -v $(SYSUSERSDIR)/$(PROGPREFIX)paste-server.sysusers \
		$(SYSUSERSDIR)/$(PROGPREFIX)paste-server.conf
ifeq ($(DESTDIR),)
	systemd-sysusers $(PROGPREFIX)paste-server.conf
	systemd-tmpfiles --create $(PROGPREFIX)paste-server.conf
	chmod -v 760 $(LIBEXECDIR)/$(PROGPREFIX)paste-server
	chown -Rv aosc-portal-paste:www-data $(LIBEXECDIR)/$(PROGPREFIX)paste-server
	@echo "===="
	@echo ""
	@echo "To start the paste server:"
	@echo ""
	@echo "    systemctl enable $(PROGPREFIX)paste-server.service --now"
	@echo ""
	@echo "===="
else
	@echo "===="
	@echo ""
	@echo "After installing the utilites to the final root directory, refer to the"
	@echo "\"Manual configuration\" section in README.md for instructions on configuring"
	@echo "the utilities and daemons."
	@echo ""
	@echo "===="
endif

clean:
	rm -rfv \
		$(OUTDIR)
