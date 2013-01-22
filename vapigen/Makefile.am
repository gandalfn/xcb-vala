include $(top_srcdir)/build/vala.am

noinst_PROGRAMS = \
    xcb-vapigen

AM_CFLAGS += \
    -I$(top_srcdir)/common

xcb_vapigen_VALAFLAGS = \
    --vapidir=$(top_srcdir)/common \
    --pkg=xcb-vala-common

xcb_vapigen_SOURCES = \
    value-type.vala \
    import.vala \
    root.vala \
    request.vala \
    reply.vala \
    class.vala \
    event.vala \
    event-copy.vala \
    error.vala \
    error-copy.vala \
    enum.vala \
    item.vala \
    field.vala \
    field-ref.vala \
    typedef.vala \
    union.vala \
    list.vala \
    value-item.vala \
    value-param.vala \
    xid-type.vala \
    xid-union.vala \
    xid-union-type.vala \
    connection.vala \
    xcb-vapigen.vala

xcb_vapigen_LDADD = \
    $(XCB_VALA_LIBS) \
    $(top_builddir)/common/libxcb-vala-common.la

VALAFILES = \
    $(filter %.vala,$(xcb_vapigen_SOURCES))

CLEANFILES += \
    xcb_vapigen_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)
