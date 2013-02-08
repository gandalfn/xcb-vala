include $(top_srcdir)/build/vala.am

noinst_PROGRAMS = \
    xcb-codegen

AM_CFLAGS += \
    -I$(top_srcdir)/common

xcb_codegen_VALAFLAGS = \
    --vapidir=$(top_srcdir)/common \
    --pkg=libvala-0.18 \
    --pkg=xcb-vala-common

xcb_codegen_SOURCES = \
    parser.vala \
    compiler.vala \
    root.vala \
    xid-class.vala \
    xid-type.vala \
    xid-union.vala \
    xid-union-type.vala \
    struct.vala \
    field.vala

xcb_codegen_LDADD = \
    $(XCB_VALA_LIBS) \
    $(top_builddir)/common/libxcb-vala-common.la

VALAFILES = \
    $(filter %.vala,$(xcb_codegen_SOURCES))

CLEANFILES += \
    xcb_codegen_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)
