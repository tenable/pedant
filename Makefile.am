AUTOMAKE_OPTIONS = subdir-objects

AM_CPPFLAGS = $(glib_CFLAGS) $(sqlite_CFLAGS)

bin_PROGRAMS = pedant

pedant_SOURCES = src/cfg.c src/cli.c src/db.c src/log.c src/pedant.c
pedant_CFLAGS = -Wall -std=c99
pedant_LDADD = $(glib_LIBS) $(sqlite_LIBS)
