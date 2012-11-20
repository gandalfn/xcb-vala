include $(top_srcdir)/build/vala.am

noinst_PROGRAMS = xcb-vala-parser

xcb_vala_parser_SOURCES = \
    set.vala \
    value.vala \
    parser.vala \
    xml-parser.vala \
    xml-object.vala \
    value-type.vala \
    import.vala \
    root.vala \
    class.vala \
    event.vala \
    event-copy.vala \
    enum.vala \
    item.vala \
    field.vala \
    field-ref.vala \
    typedef.vala \
    union.vala \
    list.vala \
    value-item.vala \
    xid-type.vala \
    xid-union.vala \
    xid-union-type.vala \
    xcb-vala-parser.vala

xcb_vala_parser_LDADD = \
    $(XCB_VALA_LIBS)

VALAFILES = $(filter %.vala,$(xcb_vala_parser_SOURCES))

CLEANFILES = \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)
