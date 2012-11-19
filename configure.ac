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
VALA_REQUIRED=0.16.0

dnl ****************************************************************************
dnl Check for vala
dnl ****************************************************************************
AM_PROG_VALAC($VALA_REQUIRED)

dnl ****************************************************************************
dnl Check for packages
dnl ****************************************************************************
PKG_CHECK_MODULES(XCB_VALA, [glib-2.0 >= $GLIB_REQUIRED
                               gobject-2.0 >= $GLIB_REQUIRED])
AC_SUBST(XCB_VALA_CFLAGS)
AC_SUBST(XCB_VALA_LIBS)

AC_CONFIG_FILES([
Makefile
src/Makefile
])

AC_OUTPUT
