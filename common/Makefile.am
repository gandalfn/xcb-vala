include $(top_srcdir)/build/vala.am

noinst_LTLIBRARIES = libxcb-vala-common.la

libxcb_vala_common_la_VALAFLAGS = \
    --header=xcb-vala-common.h \
    --library=xcb-vala-common \
    --vapi=xcb-vala-common.vapi

libxcb_vala_common_la_SOURCES = \
    set.vala \
    value.vala \
    parser.vala \
    xml-parser.vala \
    xml-object.vala

libxcb_vala_common_la_LIBADD = \
    $(XCB_VALA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libxcb_vala_common_la_SOURCES))

CLEANFILES += \
    libxcb_vala_common_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)

.NOTPARALLEL: libxcb-vala-common.la
