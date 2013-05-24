AC_PREREQ([2.69])
AC_INIT([pedant], [0.0.1])
AC_CONFIG_AUX_DIR([bin])
AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_SRCDIR([src/pedant.c])
AM_CONFIG_HEADER(src/config.h:src/config.in)

AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LEX
AC_PROG_MKDIR_P
AC_PROG_YACC

PKG_CHECK_MODULES([glib], [glib-2.0 >= 2.32.4])
PKG_CHECK_MODULES([sqlite], [sqlite3 >= 3.7.13])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
