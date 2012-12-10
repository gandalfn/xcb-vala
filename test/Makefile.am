include $(top_srcdir)/build/vala.am

noinst_PROGRAMS = \
	simple-window \
	simple-drawing \
	simple-event \
	simple-font

simple_window_VALAFLAGS = \
	--vapidir=${top_srcdir}/vapi \
	--pkg=xcb \
	--pkg=posix

simple_window_SOURCES = \
	simple-window.vala

simple_window_LDADD = \
	$(XCB_VALA_LIBS)

simple_drawing_VALAFLAGS = \
	--vapidir=${top_srcdir}/vapi \
	--pkg=xcb

simple_drawing_SOURCES = \
	simple-drawing.vala

simple_drawing_LDADD = \
	$(XCB_VALA_LIBS)

simple_event_VALAFLAGS = \
	--vapidir=${top_srcdir}/vapi \
	--pkg=xcb

simple_event_SOURCES = \
	simple-event.vala

simple_event_LDADD = \
	$(XCB_VALA_LIBS)

simple_font_VALAFLAGS = \
	--vapidir=${top_srcdir}/vapi \
	--pkg=xcb \
	--pkg=posix

simple_font_SOURCES = \
	simple-font.vala

simple_font_LDADD = \
	$(XCB_VALA_LIBS)

VALAFILES = \
    $(filter %.vala,$(simple_window_SOURCES)) \
    $(filter %.vala,$(simple_drawing_SOURCES)) \
    $(filter %.vala,$(simple_event_SOURCES)) \
    $(filter %.vala,$(simple_font_SOURCES))

CLEANFILES += \
    simple_window_vala.stamp \
    simple_drawing_vala.stamp \
    simple_event_vala.stamp \
    simple_font_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(VALAFILES:.vala=.h)
