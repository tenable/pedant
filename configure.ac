#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([pedant], [0.2.0], [mkolybabi@tenable.com])
AM_INIT_AUTOMAKE([pedant], [0.2.0])
AC_CONFIG_SRCDIR([engine/pedant.c])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
AC_CHECK_LIB([lua], [lua_version], [],[
  echo "Lua library is required for this program."
  exit -1])

# Checks for header files.
AC_CHECK_HEADERS([lua.h])
AC_CHECK_HEADERS([lualib.h])
AC_CHECK_HEADERS([lauxlib.h])
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
