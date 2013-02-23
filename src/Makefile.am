include $(top_srcdir)/build/vala.am

noinst_LTLIBRARIES = libxcb-vala-parser.la

libxcb_vala_parser_la_VALAFLAGS = \
    --header=xcb-vala-parser.h \
    --library=xcb-vala-parser \
    --vapi=xcb-vala-parser.vapi

libxcb_vala_parser_la_SOURCES = \
    set.vala \
    value.vala \
    parser.vala \
    xml-parser.vala \
    xml-object.vala \
    value-type.vala \
    doc.vala \
    brief.vala \
    description.vala \
    see.vala \
    import.vala \
    root.vala \
    request.vala \
    reply.vala \
    struct.vala \
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
    op.vala \
    bitcase.vala \
    switch.vala \
    value-item.vala \
    value-param.vala \
    xid-type.vala \
    xid-union.vala \
    xid-union-type.vala \
    connection.vala

libxcb_vala_parser_la_LIBADD = \
    $(XCB_VALA_LIBS)

noinst_PROGRAMS = \
    xcb-vapigen

xcb_vapigen_VALAFLAGS = \
    --vapidir=. \
    --pkg=xcb-vala-parser

xcb_vapigen_SOURCES = \
    xcb-vapigen.vala

xcb_vapigen_LDADD = \
    $(XCB_VALA_LIBS) \
    libxcb-vala-parser.la

VALAFILES = \
    $(filter %.vala,$(xcb_vapigen_SOURCES)) \
    $(filter %.vala,$(libxcb_vala_parser_la_SOURCES))

CLEANFILES += \
    libxcb_vala_parser_la_vala.stamp \
    xcb_vapigen_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)

.NOTPARALLEL: libxcb-vala-parser.la xcb-vapigen
