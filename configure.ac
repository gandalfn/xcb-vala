AC_INIT([xcb-vala],[0.1.0],[gandalfn@club-internet.fr],[xcb-vala])
AC_CONFIG_SRCDIR(Makefile.am)

AC_CONFIG_AUX_DIR([build])
AC_CONFIG_MACRO_DIR([build])
AC_CONFIG_HEADERS(build/config.h)

AM_INIT_AUTOMAKE([dist-bzip2])
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])
AM_MAINTAINER_MODE

dnl ****************************************************************************
dnl Check for build
dnl ****************************************************************************
AC_LANG([C])
AM_PROG_CC_C_O
AC_SEARCH_LIBS([strerror],[cposix])

dnl ****************************************************************************
dnl Check for libtool
dnl ****************************************************************************
LT_PREREQ([2.2])
LT_INIT([disable-static])

dnl ****************************************************************************
dnl Packages version required
dnl ****************************************************************************
GLIB_REQUIRED=2.32.0
VALA_REQUIRED=0.26.0
XCB_PROTO_REQUIRED=1.8

dnl ****************************************************************************
dnl Check for packages
dnl ****************************************************************************
PKG_CHECK_MODULES(XCB_VALA, [glib-2.0 >= $GLIB_REQUIRED
                             gobject-2.0 >= $GLIB_REQUIRED
                             xcb
                             xcb-glx
                             xcb-proto >= $XCB_PROTO_REQUIRED
                             xcb-randr
                             gl])
AC_SUBST(XCB_VALA_CFLAGS)
AC_SUBST(XCB_VALA_LIBS)

AM_CONDITIONAL(XCB_1_10, test "$PKG_CONFIG xcb-proto >= 1.10")

dnl ****************************************************************************
dnl Check for vala
dnl ****************************************************************************
AM_PROG_VALAC($VALA_REQUIRED)
VALA_ABI=$($VALAC --version | sed 's/Vala  *//' | cut -d'.' -f1,2)
VALA_VAPI_PATH=$($PKG_CONFIG --variable=vapidir libvala-$VALA_ABI)
AC_SUBST(VALA_VAPI_PATH)

dnl ****************************************************************************
dnl Check for valadoc
dnl ****************************************************************************
found_valadoc=no
AS_IF([test "x$enable_valadoc" != "xno"], [
    AC_PATH_PROG(VALADOC, valadoc, :)
    AS_IF([test -x "$VALADOC"], [
      found_valadoc=yes
      AC_SUBST(VALADOC)
    ], [
      AS_IF([test "x$enable_valadoc" == "xyes"], AC_MSG_ERROR([Unable to find valadoc]))
    ])
  ])

AM_CONDITIONAL(ENABLE_VALADOC, test x$found_valadoc = xyes)

XCB_XML_PATH=$($PKG_CONFIG --variable=xcbincludedir xcb-proto)
AC_SUBST(XCB_XML_PATH)

AC_CONFIG_FILES([
Makefile
src/Makefile
test/Makefile
vapi/Makefile
doc/Makefile
])

AC_OUTPUT
