include $(top_srcdir)/build/vala.am

lib_LTLIBRARIES = libxcb-vala.la

libxcb_vala_la_VALAFLAGS = \
    --vapidir=$(top_srcdir)/vapi \
    --vapidir=$(top_builddir)/vapi \
    --pkg=xcb \
    --pkg=posix \
    --pkg=gio-2.0 \
    --header=xcb-vala.h \
    --library=xcb-vala \
    --vapi=xcb-vala.vapi

libxcb_vala_la_SOURCES = \
    request.vala \
    void-request.vala \
    error.vala \
    connection.vala \
    xid.vala \
    proto/connection.vala \
    proto/no-operation-request.vala

libxcb_vala_la_LIBADD = \
    $(XCB_VALA_LIBS)

noinst_PROGRAMS = \
    test

test_VALAFLAGS = \
    --vapidir=. \
    --pkg=gio-2.0 \
    --pkg=xcb-vala

test_SOURCES = \
    test.vala

test_LDADD = \
    $(XCB_VALA_LIBS) \
    libxcb-vala.la

VALAFILES = \
    $(filter %.vala,$(test_SOURCES)) \
    $(filter %.vala,$(libxcb_vala_la_SOURCES))

CLEANFILES += \
    libxcb_vala_la_vala.stamp \
    test_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)

.NOTPARALLEL: libxcb-vala.la test
