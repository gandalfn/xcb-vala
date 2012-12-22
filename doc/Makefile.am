if ENABLE_VALADOC

VALADOC_FLAGS = \
    -D GLIB_2_32 \
    --target-glib=2.32 \
    -b $(top_srcdir)/vapi \
    --package-name xcb

VALADOC_SRCS = \
    $(top_srcdir)/vapi/xcb*.vapi

valadoc-html: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf html; \
	$(VALADOC) -o html $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

valadoc-devhelp: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf devhelp; \
	$(VALADOC) -o devhelp --doclet devhelp $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

clean-local:
	rm -rf html devhelp; \
	rm -f valadoc-html valadoc-devhelp

uninstall-hook:
	rm -rf $(DESTDIR)$(datadir)/devhelp/books/xcb

install-data-hook: devhelp
	$(MKDIR_P) $(DESTDIR)$(datadir)/devhelp/books/xcb/img
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/xcb devhelp/xcb/*.*
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/xcb/img devhelp/xcb/img/*

all-local: valadoc-html valadoc-devhelp

.NOTPARALLEL: valadoc-html valadoc-devhelp

endif
