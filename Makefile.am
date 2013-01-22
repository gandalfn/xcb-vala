SUBDIRS = common vapigen vapi codegen xcb test doc

xcbvaladocdir = ${prefix}/doc/xcb-vala
xcbvaladoc_DATA = \
    ChangeLog \
    README \
    COPYING \
    AUTHORS \
    INSTALL \
    NEWS

EXTRA_DIST = \
    $(xcbvaladoc_DATA) \
    intltool-extract.in \
    intltool-merge.in \
    intltool-update.in \
    build/common.am \
    build/vala.am

DISTCLEANFILES = \
    intltool-extract \
    intltool-merge \
    intltool-update \
    po/.intltool-merge-cache
